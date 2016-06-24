(* Direct implementation of pushouts *)
Require Import UniMath.Foundations.Basics.PartD.
Require Import UniMath.Foundations.Basics.Propositions.
Require Import UniMath.Foundations.Basics.Sets.

Require Import UniMath.CategoryTheory.precategories.
Require Import UniMath.CategoryTheory.UnicodeNotations.
Require Import UniMath.CategoryTheory.limits.initial.
Require Import UniMath.CategoryTheory.Epis.

Local Notation "a --> b" := (precategory_morphisms a b)(at level 50).


Section def_po.

  Context {C : precategory}.
  Variable hs: has_homsets C.

  Definition isPushout {a b c d : C} (p1 : a --> b) (p2 : a --> c)
             (f : b --> d) (g : c --> d) (H : p1 ;; f = p2 ;; g) : UU :=
    forall e (h : b --> e) (k : c --> e)(H : p1 ;; h = p2 ;; k),
      iscontr (total2 (fun hk : d --> e => dirprod (f ;; hk = h) (g ;; hk = k))).

  Lemma isaprop_isPushout {a b c d : C} (p1 : a --> b) (p2 : a --> c)
        (f : b --> d) (g : c --> d) (H : p1 ;; f = p2 ;; g) :
    isaprop (isPushout p1 p2 f g H).
  Proof.
    repeat (apply impred; intro).
    apply isapropiscontr.
  Qed.

  Lemma PushoutArrowUnique {a b c d : C} (p1 : a --> b) (p2 : a --> c)
        (f : b --> d) (g : c --> d) (H : p1 ;; f = p2 ;; g)
        (P : isPushout p1 p2 f g H) e (h : b --> e) (k : c --> e)
        (Hcomm : p1 ;; h = p2 ;; k)
        (w : d --> e)
        (H1 : f ;; w = h) (H2 : g ;; w = k) :
    w = (pr1 (pr1 (P e h k Hcomm))).
  Proof.
    set (T := tpair (fun hk : d --> e => dirprod (f ;; hk = h)(g ;; hk = k))
                    w (dirprodpair H1 H2)).
    set (T' := pr2 (P e h k Hcomm) T).
    exact (base_paths _ _ T').
  Qed.

  Definition Pushout {a b c : C} (p1 : a --> b) (p2 : a --> c) :=
    total2 (fun pfg : total2 (fun p : C => dirprod (b --> p) (c --> p)) =>
              total2 (fun H : p1 ;; pr1 (pr2 pfg) = p2 ;; pr2 (pr2 pfg) =>
                        isPushout p1 p2 (pr1 (pr2 pfg)) (pr2 (pr2 pfg)) H)).

  Definition Pushouts := forall (a b c : C) (p1 : a --> b) (p2 : a --> c),
      Pushout p1 p2.

  Definition hasPushouts := forall (a b c : C) (p1 : a --> b) (p2 : a --> c),
      ishinh (Pushout p1 p2).


  Definition PushoutObject {a b c : C} {p1 : a --> b} {p2 : a --> c}:
    Pushout p1 p2 -> C := fun H => pr1 (pr1 H).
  Coercion PushoutObject : Pushout >-> ob.

  Definition PushoutPr1 {a b c : C} {p1 : a --> b} {p2 : a --> c}
             (Pb : Pushout p1 p2) : b --> Pb := pr1 (pr2 (pr1 Pb)).

  Definition PushoutPr2 {a b c : C} {p1 : a --> b} {p2 : a --> c}
             (Pb : Pushout p1 p2) : c --> Pb := pr2 (pr2 (pr1 Pb)).

  Definition PushoutSqrCommutes {a b c : C} {p1 : a --> b} {p2 : a --> c}
             (Pb : Pushout p1 p2) :
    p1 ;; PushoutPr1 Pb = p2 ;; PushoutPr2 Pb.
  Proof.
    exact (pr1 (pr2 Pb)).
  Qed.

  Definition isPushout_Pushout {a b c : C} {p1 : a --> b} {p2 : a --> c}
             (P : Pushout p1 p2) :
    isPushout p1 p2 (PushoutPr1 P) (PushoutPr2 P) (PushoutSqrCommutes P).
  Proof.
    exact (pr2 (pr2 P)).
  Qed.

  Definition PushoutArrow {a b c : C} {p1 : a --> b} {p2 : a --> c}
             (Pb : Pushout p1 p2) e (h : b --> e) (k : c --> e)
             (H : p1 ;; h = p2 ;; k) :
    Pb --> e := pr1 (pr1 (isPushout_Pushout Pb e h k H)).

  Lemma PushoutArrow_PushoutPr1 {a b c : C} {p1 : a --> b} {p2 : a --> c}
        (Pb : Pushout p1 p2) e (h : b --> e) (k : c --> e)
        (H : p1 ;; h = p2 ;; k) :
    PushoutPr1 Pb ;; PushoutArrow Pb e h k H = h.
  Proof.
    exact (pr1 (pr2 (pr1 (isPushout_Pushout Pb e h k H)))).
  Qed.

  Lemma PushoutArrow_PushoutPr2 {a b c : C} {p1 : a --> b} {p2 : a --> c}
        (Pb : Pushout p1 p2) e (h : b --> e) (k : c --> e)
        (H : p1 ;; h = p2 ;; k) :
    PushoutPr2 Pb ;; PushoutArrow Pb e h k H = k.
  Proof.
    exact (pr2 (pr2 (pr1 (isPushout_Pushout Pb e h k H)))).
  Qed.

  Definition mk_Pushout {a b c : C} (p1 : C⟦a, b⟧) (p2 : C⟦a, c⟧)
             (d : C) (f : C⟦b,d⟧) (g : C ⟦c,d⟧)
             (H : p1 ;; f = p2 ;; g)
             (ispb : isPushout p1 p2 f g H)
    : Pushout p1 p2.
  Proof.
    simple refine (tpair _ _ _ ).
    - simple refine (tpair _ _ _ ).
      + apply d.
      + exists f.
        exact g.
    - exists H.
      apply ispb.
  Defined.

  Definition mk_isPushout {a b c d : C} (p1 : C ⟦a, b⟧) (p2 : C ⟦a, c⟧)
             (f : C⟦b,d⟧) (g : C⟦c,d⟧) (H : p1 ;; f = p2 ;; g) :
    (forall e (h : C ⟦b, e⟧) (k : C⟦c,e⟧)(Hk : p1 ;; h = p2 ;; k),
        iscontr (total2 (fun hk : C⟦d,e⟧ => dirprod (f ;; hk = h)(g ;; hk = k))))
    →
    isPushout p1 p2 f g H.
  Proof.
    intros H' x cx k sqr.
    apply H'. assumption.
  Defined.

  Lemma MorphismsIntoPushoutEqual {a b c d : C} {p1 : a --> b} {p2 : a --> c}
        {f : b --> d} {g : c --> d} {H : p1 ;; f = p2 ;; g}
        (P : isPushout p1 p2 f g H) {e}
        (w w': d --> e)
        (H1 : f ;; w = f ;; w') (H2 : g ;; w = g ;; w')
    : w = w'.
  Proof.
    assert (Hw : p1 ;; f ;; w = p2 ;; g ;; w).
    { rewrite H. apply idpath. }
    assert (Hw' : p1 ;; f ;; w' = p2 ;; g ;; w').
    { rewrite H. apply idpath. }
    set (Pb := mk_Pushout _ _ _ _ _ _ P).
    rewrite <- assoc in Hw. rewrite <- assoc in Hw.
    set (Xw := PushoutArrow Pb e (f;;w) (g;;w) Hw).
    pathvia Xw; [ apply PushoutArrowUnique; apply idpath |].
    apply pathsinv0.
    apply PushoutArrowUnique. apply pathsinv0. apply H1.
    apply pathsinv0. apply H2.
  Qed.


  Definition identity_is_Pushout_input {a b c : C}{p1 : a --> b}
             {p2 : a --> c} (Pb : Pushout p1 p2) :
    total2 (fun hk : Pb --> Pb =>
              dirprod (PushoutPr1 Pb ;; hk = PushoutPr1 Pb)
                      (PushoutPr2 Pb ;; hk = PushoutPr2 Pb)).
  Proof.
    exists (identity Pb).
    apply dirprodpair; apply id_right.
  Defined.

  Lemma PushoutEndo_is_identity {a b c : C}{p1 : a --> b} {p2 : a --> c}
        (Pb : Pushout p1 p2) (k : Pb --> Pb)
        (kH1 : PushoutPr1 Pb ;; k = PushoutPr1 Pb)
        (kH2 : PushoutPr2 Pb ;; k = PushoutPr2 Pb) :
    identity Pb = k.
  Proof.
    set (H1 := tpair ((fun hk : Pb --> Pb => dirprod (_ ;; hk = _)(_ ;; hk = _)))
                     k (dirprodpair kH1 kH2)).
    assert (H2 : identity_is_Pushout_input Pb = H1).
    - apply proofirrelevance.
      apply isapropifcontr.
      apply (isPushout_Pushout Pb).
      apply PushoutSqrCommutes.
    - apply (base_paths _ _ H2).
  Qed.


  Definition from_Pushout_to_Pushout {a b c : C}{p1 : a --> b} {p2 : a --> c}
             (Pb Pb': Pushout p1 p2) : Pb --> Pb'.
  Proof.
    apply (PushoutArrow Pb Pb' (PushoutPr1 _ ) (PushoutPr2 _)).
    exact (PushoutSqrCommutes _ ).
  Defined.


  Lemma are_inverses_from_Pushout_to_Pushout {a b c : C}{p1 : a --> b}
        {p2 : a --> c} (Pb Pb': Pushout p1 p2) :
    is_inverse_in_precat (from_Pushout_to_Pushout Pb' Pb)
                         (from_Pushout_to_Pushout Pb Pb').
  Proof.
    split.

    (** First identity *)
    apply pathsinv0.
    apply PushoutEndo_is_identity.
    unfold from_Pushout_to_Pushout.
    unfold from_Pushout_to_Pushout.
    rewrite assoc.
    rewrite PushoutArrow_PushoutPr1.
    rewrite PushoutArrow_PushoutPr1.
    apply idpath.

    unfold from_Pushout_to_Pushout.
    unfold from_Pushout_to_Pushout.
    rewrite assoc.
    rewrite PushoutArrow_PushoutPr2.
    rewrite PushoutArrow_PushoutPr2.
    apply idpath.

    (** Second identity *)
    apply pathsinv0.
    apply PushoutEndo_is_identity.
    unfold from_Pushout_to_Pushout.
    unfold from_Pushout_to_Pushout.
    rewrite assoc.
    rewrite PushoutArrow_PushoutPr1.
    rewrite PushoutArrow_PushoutPr1.
    apply idpath.

    unfold from_Pushout_to_Pushout.
    unfold from_Pushout_to_Pushout.
    rewrite assoc.
    rewrite PushoutArrow_PushoutPr2.
    rewrite PushoutArrow_PushoutPr2.
    apply idpath.
  Qed.


  Lemma isiso_from_Pushout_to_Pushout {a b c : C}{p1 : a --> b} {p2 : a --> c}
        (Pb Pb': Pushout p1 p2) :
    is_isomorphism (from_Pushout_to_Pushout Pb Pb').
  Proof.
    apply (is_iso_qinv _ (from_Pushout_to_Pushout Pb' Pb)).
    apply are_inverses_from_Pushout_to_Pushout.
  Defined.


  Definition iso_from_Pushout_to_Pushout {a b c : C}{p1 : a --> b} {p2 : a --> c}
             (Pb Pb': Pushout p1 p2) : iso Pb Pb' :=
    tpair _ _ (isiso_from_Pushout_to_Pushout Pb Pb').

  Section Universal_Unique.

    Hypothesis H : is_category C.


    Lemma inv_from_iso_iso_from_Pushout (a b c : C) (p1 : a --> b) (p2 : a --> c)
          (Pb : Pushout p1 p2) (Pb' : Pushout p1 p2):
      inv_from_iso (iso_from_Pushout_to_Pushout Pb Pb')
      = from_Pushout_to_Pushout Pb' Pb.
    Proof.
      apply pathsinv0.
      apply inv_iso_unique'.
      set (T:= are_inverses_from_Pushout_to_Pushout Pb' Pb).
      apply (pr1 T).
    Qed.


    Lemma isaprop_Pushouts: isaprop Pushouts.
    Proof.
      apply impred; intro a; apply impred; intro b; apply impred; intro c;
        apply impred; intro p1; apply impred; intro p2;
          apply invproofirrelevance.
      intros Pb Pb'.
      apply subtypeEquality.
      - intro; apply isofhleveltotal2.
        + apply hs.
        + intros; apply isaprop_isPushout.
      - apply (total2_paths
                 (isotoid _ H (iso_from_Pushout_to_Pushout Pb Pb' ))).
        rewrite transportf_dirprod, transportf_isotoid', transportf_isotoid'.
        fold (PushoutPr1 Pb). fold (PushoutPr2 Pb).
        use (dirprodeq); simpl.

        destruct Pb as [Cone bla];
          destruct Pb' as [Cone' bla'];
          simpl in *.

        destruct Cone as [p [h k]];
          destruct Cone' as [p' [h' k']];
          simpl in *.

        unfold from_Pushout_to_Pushout.
        rewrite PushoutArrow_PushoutPr1.
        apply idpath.

        unfold from_Pushout_to_Pushout.
        rewrite PushoutArrow_PushoutPr2.
        apply idpath.
    Qed.

  End Universal_Unique.

End def_po.


(** In this section we prove that the pushout of an epimorphism is an
  epimorphism. *)
Section epi_po.

  Variable C : precategory.

  (** The pushout of an epimorphism is an epimorphism. *)
  Lemma EpiPushoutEpi {a b c : C} (E : Epi _ a b) (g : a --> c)
        (PB : Pushout E g) : isEpi _ (PushoutPr2 PB).
  Proof.
    apply mk_isEpi. intros z g0 h X.
    use (MorphismsIntoPushoutEqual (isPushout_Pushout PB) _ _ _ X).

    set (X0 := maponpaths (fun f => g ;; f) X); simpl in X0.
    rewrite assoc in X0. rewrite assoc in X0.
    rewrite <- (PushoutSqrCommutes PB) in X0.
    rewrite <- assoc in X0. rewrite <- assoc in X0.
    apply (pr2 E _ _ _) in X0. apply X0.
  Defined.

  (** Same result for the other morphism *)
  Lemma EpiPushoutEpi' {a b c : C} (f : a --> b) (E : Epi _ a c)
        (PB : Pushout f E) : isEpi _ (PushoutPr1 PB).
  Proof.
    apply mk_isEpi. intros z g0 h X.
    use (MorphismsIntoPushoutEqual (isPushout_Pushout PB) _ _ X).

    set (X0 := maponpaths (fun f' => f ;; f') X); simpl in X0.
    rewrite assoc in X0. rewrite assoc in X0.
    rewrite (PushoutSqrCommutes PB) in X0.
    rewrite <- assoc in X0. rewrite <- assoc in X0.
    apply (pr2 E _ _ _) in X0. apply X0.
  Defined.

End epi_po.

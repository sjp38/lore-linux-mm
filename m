Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id C84BA6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 09:13:01 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so854481vcb.14
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 06:13:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1331622432-24683-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1331622432-24683-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1331622432-24683-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Tue, 13 Mar 2012 21:13:00 +0800
Message-ID: <CAJd=RBA+D0MyjwuCNp3WtKRq-d3F_t9rKHLgmyLhznhZ9HjG4g@mail.gmail.com>
Subject: Re: [PATCH -V3 1/8] hugetlb: rename max_hstate to hugetlb_max_hstate
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, Mar 13, 2012 at 3:07 PM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>
> We will be using this from other subsystems like memcg
> in later patches.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---

Acked-by: Hillf Danton <dhillf@gmail.com>

> =C2=A0mm/hugetlb.c | =C2=A0 14 +++++++-------
> =C2=A01 files changed, 7 insertions(+), 7 deletions(-)
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 5f34bd8..d623e71 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -34,7 +34,7 @@ const unsigned long hugetlb_zero =3D 0, hugetlb_infinit=
y =3D ~0UL;
> =C2=A0static gfp_t htlb_alloc_mask =3D GFP_HIGHUSER;
> =C2=A0unsigned long hugepages_treat_as_movable;
>
> -static int max_hstate;
> +static int hugetlb_max_hstate;
> =C2=A0unsigned int default_hstate_idx;
> =C2=A0struct hstate hstates[HUGE_MAX_HSTATE];
>
> @@ -46,7 +46,7 @@ static unsigned long __initdata default_hstate_max_huge=
_pages;
> =C2=A0static unsigned long __initdata default_hstate_size;
>
> =C2=A0#define for_each_hstate(h) \
> - =C2=A0 =C2=A0 =C2=A0 for ((h) =3D hstates; (h) < &hstates[max_hstate]; =
(h)++)
> + =C2=A0 =C2=A0 =C2=A0 for ((h) =3D hstates; (h) < &hstates[hugetlb_max_h=
state]; (h)++)
>
> =C2=A0/*
> =C2=A0* Protects updates to hugepage_freelists, nr_huge_pages, and free_h=
uge_pages
> @@ -1808,9 +1808,9 @@ void __init hugetlb_add_hstate(unsigned order)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0printk(KERN_WARNIN=
G "hugepagesz=3D specified twice, ignoring\n");
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> - =C2=A0 =C2=A0 =C2=A0 BUG_ON(max_hstate >=3D HUGE_MAX_HSTATE);
> + =C2=A0 =C2=A0 =C2=A0 BUG_ON(hugetlb_max_hstate >=3D HUGE_MAX_HSTATE);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(order =3D=3D 0);
> - =C2=A0 =C2=A0 =C2=A0 h =3D &hstates[max_hstate++];
> + =C2=A0 =C2=A0 =C2=A0 h =3D &hstates[hugetlb_max_hstate++];
> =C2=A0 =C2=A0 =C2=A0 =C2=A0h->order =3D order;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0h->mask =3D ~((1ULL << (order + PAGE_SHIFT)) -=
 1);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0h->nr_huge_pages =3D 0;
> @@ -1831,10 +1831,10 @@ static int __init hugetlb_nrpages_setup(char *s)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0static unsigned long *last_mhp;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0* !max_hstate means we haven't parsed a huge=
pagesz=3D parameter yet,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* !hugetlb_max_hstate means we haven't parse=
d a hugepagesz=3D parameter yet,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * so this hugepages=3D parameter goes to the =
"default hstate".
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (!max_hstate)
> + =C2=A0 =C2=A0 =C2=A0 if (!hugetlb_max_hstate)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mhp =3D &default_h=
state_max_huge_pages;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0else
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0mhp =3D &parsed_hs=
tate->max_huge_pages;
> @@ -1853,7 +1853,7 @@ static int __init hugetlb_nrpages_setup(char *s)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * But we need to allocate >=3D MAX_ORDER hsta=
tes here early to still
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * use the bootmem allocator.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 if (max_hstate && parsed_hstate->order >=3D MAX_OR=
DER)
> + =C2=A0 =C2=A0 =C2=A0 if (hugetlb_max_hstate && parsed_hstate->order >=
=3D MAX_ORDER)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hugetlb_hstate_all=
oc_pages(parsed_hstate);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0last_mhp =3D mhp;
> --
> 1.7.9
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

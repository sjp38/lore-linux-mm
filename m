Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 882E9C3A59B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:22:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D94820644
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:22:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D94820644
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E89996B02E8; Thu, 15 Aug 2019 13:22:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E12F66B02EA; Thu, 15 Aug 2019 13:22:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CB3866B02EB; Thu, 15 Aug 2019 13:22:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0204.hostedemail.com [216.40.44.204])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA486B02E8
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:22:58 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 10CBD181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:22:58 +0000 (UTC)
X-FDA: 75825332436.07.hole74_7120291e25c34
X-HE-Tag: hole74_7120291e25c34
X-Filterd-Recvd-Size: 4494
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf02.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:22:57 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 43F523082E51;
	Thu, 15 Aug 2019 17:22:56 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 3D85710018F9;
	Thu, 15 Aug 2019 17:22:55 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:22:53 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>, Jan Kara <jack@suse.cz>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Michal Hocko <mhocko@suse.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] mm/migrate: remove the duplicated code
 migrate_vma_collect_hole()
Message-ID: <20190815172253.GE30916@redhat.com>
References: <1565078411-27082-1-git-send-email-kernelfans@gmail.com>
 <1565078411-27082-3-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1565078411-27082-3-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 15 Aug 2019 17:22:56 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 04:00:11PM +0800, Pingfan Liu wrote:
> After the previous patch which sees hole as invalid source,
> migrate_vma_collect_hole() has the same code as migrate_vma_collect_ski=
p().
> Removing the duplicated code.

NAK this one too given previous NAK.

>=20
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Jan Kara <jack@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> To: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  mm/migrate.c | 22 +++-------------------
>  1 file changed, 3 insertions(+), 19 deletions(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 832483f..95e038d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2128,22 +2128,6 @@ struct migrate_vma {
>  	unsigned long		end;
>  };
> =20
> -static int migrate_vma_collect_hole(unsigned long start,
> -				    unsigned long end,
> -				    struct mm_walk *walk)
> -{
> -	struct migrate_vma *migrate =3D walk->private;
> -	unsigned long addr;
> -
> -	for (addr =3D start & PAGE_MASK; addr < end; addr +=3D PAGE_SIZE) {
> -		migrate->src[migrate->npages] =3D 0;
> -		migrate->dst[migrate->npages] =3D 0;
> -		migrate->npages++;
> -	}
> -
> -	return 0;
> -}
> -
>  static int migrate_vma_collect_skip(unsigned long start,
>  				    unsigned long end,
>  				    struct mm_walk *walk)
> @@ -2173,7 +2157,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
> =20
>  again:
>  	if (pmd_none(*pmdp))
> -		return migrate_vma_collect_hole(start, end, walk);
> +		return migrate_vma_collect_skip(start, end, walk);
> =20
>  	if (pmd_trans_huge(*pmdp)) {
>  		struct page *page;
> @@ -2206,7 +2190,7 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  				return migrate_vma_collect_skip(start, end,
>  								walk);
>  			if (pmd_none(*pmdp))
> -				return migrate_vma_collect_hole(start, end,
> +				return migrate_vma_collect_skip(start, end,
>  								walk);
>  		}
>  	}
> @@ -2337,7 +2321,7 @@ static void migrate_vma_collect(struct migrate_vm=
a *migrate)
> =20
>  	mm_walk.pmd_entry =3D migrate_vma_collect_pmd;
>  	mm_walk.pte_entry =3D NULL;
> -	mm_walk.pte_hole =3D migrate_vma_collect_hole;
> +	mm_walk.pte_hole =3D migrate_vma_collect_skip;
>  	mm_walk.hugetlb_entry =3D NULL;
>  	mm_walk.test_walk =3D NULL;
>  	mm_walk.vma =3D migrate->vma;
> --=20
> 2.7.5
>=20


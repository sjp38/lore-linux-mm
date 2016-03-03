Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3A36B0254
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 03:41:57 -0500 (EST)
Received: by mail-io0-f169.google.com with SMTP id n190so20380568iof.0
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 00:41:57 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id c26si16100621ioj.161.2016.03.03.00.41.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 00:41:56 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 11/11] mm: memory_hotplug: memory hotremove supports
 thp migration
Date: Thu, 3 Mar 2016 08:40:17 +0000
Message-ID: <20160303084015.GA29281@hori1.linux.bs1.fc.nec.co.jp>
References: <1456990918-30906-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1456990918-30906-12-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1456990918-30906-12-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A79654ED4814534FB97A969B480AAC2E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Mar 03, 2016 at 04:41:58PM +0900, Naoya Horiguchi wrote:
> This patch enables thp migration for memory hotremove. Stub definition of
> prep_transhuge_page() is added for CONFIG_TRANSPARENT_HUGEPAGE=3Dn.
>=20
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/huge_mm.h | 3 +++
>  mm/memory_hotplug.c     | 8 ++++++++
>  mm/page_isolation.c     | 8 ++++++++
>  3 files changed, 19 insertions(+)
>=20
> diff --git v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/huge_mm.h v4.5-r=
c5-mmotm-2016-02-24-16-18_patched/include/linux/huge_mm.h
> index 09b215d..7944346 100644
> --- v4.5-rc5-mmotm-2016-02-24-16-18/include/linux/huge_mm.h
> +++ v4.5-rc5-mmotm-2016-02-24-16-18_patched/include/linux/huge_mm.h
> @@ -175,6 +175,9 @@ static inline bool thp_migration_supported(void)
>  #define transparent_hugepage_enabled(__vma) 0
> =20
>  #define transparent_hugepage_flags 0UL
> +static inline void prep_transhuge_page(struct page *page)
> +{
> +}
>  static inline int
>  split_huge_page_to_list(struct page *page, struct list_head *list)
>  {

According to the warnings from kbuild bot, this chunk should come with
patch 8/11 or earlier. I'll fix this.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

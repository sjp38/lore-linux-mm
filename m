Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id DF23A6B0008
	for <linux-mm@kvack.org>; Mon, 23 Jul 2018 06:48:52 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id c23-v6so14242pfi.3
        for <linux-mm@kvack.org>; Mon, 23 Jul 2018 03:48:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d19-v6si9470740pfm.226.2018.07.23.03.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Jul 2018 03:48:51 -0700 (PDT)
Date: Mon, 23 Jul 2018 12:48:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 1/2] mm: clarify semantics of reserved pages
Message-ID: <20180723104847.GB31229@dhcp22.suse.cz>
References: <20180720123422.10127-1-david@redhat.com>
 <20180720123422.10127-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180720123422.10127-2-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Huang Ying <ying.huang@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Dave Young <dyoung@redhat.com>, Baoquan He <bhe@redhat.com>, =?iso-8859-1?Q?Marc-Andr=E9?= Lureau <marcandre.lureau@redhat.com>, Petr Tesarik <ptesarik@suse.cz>

On Fri 20-07-18 14:34:21, David Hildenbrand wrote:
> The reserved bit once was used to hinder pages from getting swapped. While
> this still works,

Does it? There is no single PageReserved check in the reclaim path. I
have no idea when we stopped checking but it must be loooong ago.

> the semantics are a little bit stronger nowadays: The
> page should never be touched by anybody in the system except by the owner.
> The original comment already gave a hint about that.
> 
> So especially, these pages should also not be dumped by dumping tools.
> Let's make that more clear by updating the comment.
> 
> This will be useful especially in the future in virtual environments where
> pages marked with the reserved bit might no longer be accessible.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Matthew Wilcox <mawilcox@microsoft.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Miles Chen <miles.chen@mediatek.com>
> Cc: Dave Young <dyoung@redhat.com>
> Cc: Baoquan He <bhe@redhat.com>
> Cc: "Marc-Andre Lureau" <marcandre.lureau@redhat.com>
> Cc: Petr Tesarik <ptesarik@suse.cz>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

for this change
> ---
>  include/linux/page-flags.h | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 901943e4754b..ba81e11a868c 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -17,8 +17,8 @@
>  /*
>   * Various page->flags bits:
>   *
> - * PG_reserved is set for special pages, which can never be swapped out. Some
> - * of them might not even exist...
> + * PG_reserved is set for special pages, which should never be touched (read/
> + * write) by anybody except their owner. Some of them might not even exist.
>   *
>   * The PG_private bitflag is set on pagecache pages if they contain filesystem
>   * specific data (which is normally at page->private). It can be used by
> -- 
> 2.17.1
> 

-- 
Michal Hocko
SUSE Labs

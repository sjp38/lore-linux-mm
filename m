Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id C392C6B0264
	for <linux-mm@kvack.org>; Mon,  3 Aug 2015 13:36:05 -0400 (EDT)
Received: by qgeh16 with SMTP id h16so93251727qge.3
        for <linux-mm@kvack.org>; Mon, 03 Aug 2015 10:36:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z14si17602551qhd.23.2015.08.03.10.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Aug 2015 10:36:04 -0700 (PDT)
Date: Mon, 3 Aug 2015 19:33:58 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: vm_flags, vm_flags_t and __nocast
Message-ID: <20150803173358.GA20243@redhat.com>
References: <201507241628.EnDEXbaF%fengguang.wu@intel.com> <20150724100940.GB22732@node.dhcp.inet.fi> <alpine.DEB.2.10.1507241314300.5215@chino.kir.corp.google.com> <20150803155155.7F8546E@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150803155155.7F8546E@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On 08/03, Kirill A. Shutemov wrote:
>
> Subject: [PATCH] mm: drop __nocast from vm_flags_t definition
>
> __nocast does no good for vm_flags_t. It only produces useless sparse
> warnings.
>
> Let's drop it.

Personally I like this change.

I too see no value in this "__nocast".

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  include/linux/mm_types.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 1fb4e46a1736..b9134cc27c4d 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -226,7 +226,7 @@ struct page_frag {
>  #endif
>  };
>  
> -typedef unsigned long __nocast vm_flags_t;
> +typedef unsigned long vm_flags_t;
>  
>  /*
>   * A region containing a mapping of a non-memory backed file under NOMMU
> -- 
> 2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

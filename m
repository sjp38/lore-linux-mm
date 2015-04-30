Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id B4DE36B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 12:22:03 -0400 (EDT)
Received: by wgin8 with SMTP id n8so68128710wgi.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 09:22:03 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id ml5si3596172wic.74.2015.04.30.09.22.01
        for <linux-mm@kvack.org>;
        Thu, 30 Apr 2015 09:22:02 -0700 (PDT)
Date: Thu, 30 Apr 2015 19:22:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 07/11] mm: debug: VM_BUG()
Message-ID: <20150430162201.GC17344@node.dhcp.inet.fi>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
 <1429044993-1677-8-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429044993-1677-8-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Apr 14, 2015 at 04:56:29PM -0400, Sasha Levin wrote:
> VM_BUG() complements VM_BUG_ON() just like with WARN() and WARN_ON().
> 
> This lets us format custom strings to output when a VM_BUG() is hit.
> 
> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
> ---
>  include/linux/mmdebug.h |   10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
> index 8b3f5a0..42f41e3 100644
> --- a/include/linux/mmdebug.h
> +++ b/include/linux/mmdebug.h
> @@ -12,7 +12,14 @@ char *format_page(struct page *page, char *buf, char *end);
>  #ifdef CONFIG_DEBUG_VM
>  char *format_vma(const struct vm_area_struct *vma, char *buf, char *end);
>  char *format_mm(const struct mm_struct *mm, char *buf, char *end);
> -#define VM_BUG_ON(cond) BUG_ON(cond)
> +#define VM_BUG(cond, fmt...)						\

vm_bugf() ? ;)

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

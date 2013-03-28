Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id F1C456B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 11:51:14 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id f4so7686334oah.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 08:51:14 -0700 (PDT)
Date: Thu, 28 Mar 2013 08:51:09 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 1/2] hugetlbfs: stop setting VM_DONTDUMP in initializing
 vma(VM_HUGETLB)
Message-ID: <20130328155109.GA13075@kroah.com>
References: <1364485358-8745-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364485358-8745-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Konstantin Khlebnikov <khlebnikov@openvz.org>

On Thu, Mar 28, 2013 at 11:42:37AM -0400, Naoya Horiguchi wrote:
> Currently we fail to include any data on hugepages into coredump,
> because VM_DONTDUMP is set on hugetlbfs's vma. This behavior was recently
> introduced by commit 314e51b98 "mm: kill vma flag VM_RESERVED and
> mm->reserved_vm counter". This looks to me a serious regression,
> so let's fix it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
> ---
>  fs/hugetlbfs/inode.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)


<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

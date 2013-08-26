Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id D3E066B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 11:47:50 -0400 (EDT)
Date: Mon, 26 Aug 2013 11:47:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1377532055-dwlp8gs5-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130826090837.GA6543@hacker.(null)>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377506774-5377-9-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130826090837.GA6543@hacker.(null)>
Subject: Re: [PATCH v4 9/10] mm/hwpoison: change permission of
 corrupt-pfn/unpoison-pfn to 0400
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 26, 2013 at 05:08:38PM +0800, Wanpeng Li wrote:
> On Mon, Aug 26, 2013 at 04:46:13PM +0800, Wanpeng Li wrote:
> >Hwpoison inject doesn't implement read method for corrupt-pfn/unpoison-pfn
> >attributes:
> >
> ># cat /sys/kernel/debug/hwpoison/corrupt-pfn 
> >cat: /sys/kernel/debug/hwpoison/corrupt-pfn: Permission denied
> ># cat /sys/kernel/debug/hwpoison/unpoison-pfn 
> >cat: /sys/kernel/debug/hwpoison/unpoison-pfn: Permission denied
> >
> >This patch change the permission of corrupt-pfn/unpoison-pfn to 0400.
> >
> >Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> >---
> > mm/hwpoison-inject.c | 4 ++--
> > 1 file changed, 2 insertions(+), 2 deletions(-)
> >
> >diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
> >index 3a61efc..8b77bfd 100644
> >--- a/mm/hwpoison-inject.c
> >+++ b/mm/hwpoison-inject.c
> >@@ -88,12 +88,12 @@ static int pfn_inject_init(void)
> > 	 * hardware status change, hence do not require hardware support.
> > 	 * They are mainly for testing hwpoison in software level.
> > 	 */
> >-	dentry = debugfs_create_file("corrupt-pfn", 0600, hwpoison_dir,
> >+	dentry = debugfs_create_file("corrupt-pfn", 0400, hwpoison_dir,
> > 					  NULL, &hwpoison_fops);
> > 	if (!dentry)
> > 		goto fail;
> >
> >-	dentry = debugfs_create_file("unpoison-pfn", 0600, hwpoison_dir,
> >+	dentry = debugfs_create_file("unpoison-pfn", 0400, hwpoison_dir,
> > 				     NULL, &unpoison_fops);
> > 	if (!dentry)
> > 		goto fail;
> >-- 
> >1.8.1.2
> 
> Fix this patch: 

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

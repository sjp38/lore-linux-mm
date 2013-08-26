Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 1D59E6B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 05:08:47 -0400 (EDT)
Received: from /spool/local
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 27 Aug 2013 06:02:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 457F73578050
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:08:41 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7Q98Up22163154
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:08:30 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r7Q98eUe008080
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 19:08:40 +1000
Date: Mon, 26 Aug 2013 17:08:38 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 9/10] mm/hwpoison: change permission of
 corrupt-pfn/unpoison-pfn to 0400
Message-ID: <20130826090837.GA6543@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <1377506774-5377-9-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Content-Disposition: inline
In-Reply-To: <1377506774-5377-9-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Aug 26, 2013 at 04:46:13PM +0800, Wanpeng Li wrote:
>Hwpoison inject doesn't implement read method for corrupt-pfn/unpoison-pfn
>attributes:
>
># cat /sys/kernel/debug/hwpoison/corrupt-pfn 
>cat: /sys/kernel/debug/hwpoison/corrupt-pfn: Permission denied
># cat /sys/kernel/debug/hwpoison/unpoison-pfn 
>cat: /sys/kernel/debug/hwpoison/unpoison-pfn: Permission denied
>
>This patch change the permission of corrupt-pfn/unpoison-pfn to 0400.
>
>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>---
> mm/hwpoison-inject.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
>
>diff --git a/mm/hwpoison-inject.c b/mm/hwpoison-inject.c
>index 3a61efc..8b77bfd 100644
>--- a/mm/hwpoison-inject.c
>+++ b/mm/hwpoison-inject.c
>@@ -88,12 +88,12 @@ static int pfn_inject_init(void)
> 	 * hardware status change, hence do not require hardware support.
> 	 * They are mainly for testing hwpoison in software level.
> 	 */
>-	dentry = debugfs_create_file("corrupt-pfn", 0600, hwpoison_dir,
>+	dentry = debugfs_create_file("corrupt-pfn", 0400, hwpoison_dir,
> 					  NULL, &hwpoison_fops);
> 	if (!dentry)
> 		goto fail;
>
>-	dentry = debugfs_create_file("unpoison-pfn", 0600, hwpoison_dir,
>+	dentry = debugfs_create_file("unpoison-pfn", 0400, hwpoison_dir,
> 				     NULL, &unpoison_fops);
> 	if (!dentry)
> 		goto fail;
>-- 
>1.8.1.2

Fix this patch: 




--opJtzjQTFsWo+cga
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0009-9.patch"


--opJtzjQTFsWo+cga--

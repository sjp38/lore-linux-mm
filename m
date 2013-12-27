Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 790C56B0031
	for <linux-mm@kvack.org>; Thu, 26 Dec 2013 19:22:08 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so8623253pbc.41
        for <linux-mm@kvack.org>; Thu, 26 Dec 2013 16:22:08 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id eb3si22340010pbc.206.2013.12.26.16.22.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Dec 2013 16:22:07 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 27 Dec 2013 05:52:03 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 6FF521258051
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 05:53:20 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBR0LvIU3670510
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 05:51:57 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rBR0Lxeg031264
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 05:51:59 +0530
Date: Fri, 27 Dec 2013 08:21:57 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: zswap: Add kernel parameters for zswap in
 kernel-parameters.txt
Message-ID: <52bcc82f.23b6440a.36ed.11e4SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1388061179-26624-1-git-send-email-standby24x7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1388061179-26624-1-git-send-email-standby24x7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masanari Iida <standby24x7@gmail.com>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Masanari,
On Thu, Dec 26, 2013 at 09:32:59PM +0900, Masanari Iida wrote:
>This patch adds kernel parameters for zswap.
>
>Signed-off-by: Masanari Iida <standby24x7@gmail.com>
>---
> Documentation/kernel-parameters.txt | 13 +++++++++++++
> 1 file changed, 13 insertions(+)
>
>diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
>index 60a822b..209730af 100644
>--- a/Documentation/kernel-parameters.txt
>+++ b/Documentation/kernel-parameters.txt
>@@ -3549,6 +3549,19 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
> 			Format:
> 			<irq>,<irq_mask>,<io>,<full_duplex>,<do_sound>,<lockup_hack>[,<irq2>[,<irq3>[,<irq4>]]]
>
>+	zswap.compressor= [KNL]
>+			Specify compressor algorithm.
>+			By default, set to lzo.
>+
>+	zswap.enabled=	[KNL]
>+			Format: <0|1>
>+			0: Disable zswap (default)
>+			1: Enable zswap
>+			See more information, Documentations/vm/zswap.txt
>+
>+	zswap.max_pool_percent=	[KNL]
>+			The maximum percentage of memory that the compressed
>+			pool can occupy. By default, set to 20.
> __________

Dan explained why there is no description in kernel-parameters.txt.

http://marc.info/?l=linux-mm&m=136121736903140&w=2

Regards,
Wanpeng Li 

>
> TODO:
>-- 
>1.8.5.2.192.g7794a68
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

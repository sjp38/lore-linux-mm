Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 911A76B005D
	for <linux-mm@kvack.org>; Sat,  8 Dec 2012 09:55:08 -0500 (EST)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: mm 
Date: Sat,  8 Dec 2012 07:18:49 -0800
Message-Id: <1354979929-18462-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kys@microsoft.com

While running some compilation load on a Linux-next kernel of December 2,
2012, I see the following messages:

[ 1164.988521] BUG: Bad rss-counter state mm:ffff88002f8aa740 idx:1 val:-2
[ 5042.442664] BUG: Bad rss-counter state mm:ffff88002f029140 idx:1 val:-1
[ 5046.108841] BUG: Bad rss-counter state mm:ffff88000d052040 idx:1 val:-1
[ 7534.904609] BUG: Bad rss-counter state mm:ffff88002faf9740 idx:1 val:-1

Regards,

K. Y

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

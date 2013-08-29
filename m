Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 9D66E6B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 02:17:32 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 29 Aug 2013 16:03:46 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0F0D22BB0054
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 16:17:23 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r7T6HBMr63635574
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 16:17:11 +1000
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r7T6HL0E030059
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 16:17:22 +1000
Date: Thu, 29 Aug 2013 14:17:19 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 1/10] mm/hwpoison: fix lose PG_dirty flag for errors
 on mlocked pages
Message-ID: <20130829061719.GA30216@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1377506774-5377-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130829060015.GK19750@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130829060015.GK19750@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Tony Luck <tony.luck@intel.com>, gong.chen@linux.intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 29, 2013 at 08:00:15AM +0200, Andi Kleen wrote:
>
>I did a quick read and the patches look all good to me

Thanks for your review Andi. ;-)

>(except the one just moving code around -- seems pointless,
>forward declarations are totally fine)

It has already been merged in -mm tree, I think the patch is harmless.

Regards,
Wanpeng Li 

>
>Acked-by: Andi Kleen <ak@linux.intel.com>
>
>-Andi
>-- 
>ak@linux.intel.com -- Speaking for myself only.
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

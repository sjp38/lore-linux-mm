Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C372E6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 19:23:54 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 09:23:52 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BCDEB2BB0054
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:23:48 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GN79sJ9896446
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:07:10 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8GNNlIK020429
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:23:47 +1000
Date: Tue, 17 Sep 2013 07:23:45 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v2 1/4] mm/hwpoison: fix traverse hugetlbfs page
 to avoid printk flood
Message-ID: <20130916232345.GA3241@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130915001352.GQ18242@two.firstfloor.org>
 <3908561D78D1C84285E8C5FCA982C28F31CFD2D6@ORSMSX106.amr.corp.intel.com>
 <1379369397-ld8lbcn-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1379369397-ld8lbcn-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Sep 16, 2013 at 06:09:57PM -0400, Naoya Horiguchi wrote:
>On Mon, Sep 16, 2013 at 09:50:06PM +0000, Luck, Tony wrote:
>> This is good - but the real solution is to stop poisoning entire huge pages ... they should
>> be broken into 4K pages and just one 4K page should be poisoned.
>> 
>> Naoya Horiguchi: I thought that you were looking at this problem some months ago. Any progress?
>
>Sorry, I have no meaningful progress on this. Splitting hugepages is not
>a trivial operation, and introduce more complexity on hugetlbfs code.
>I don't hit on any usecase of it rather than memory failure, so I'm not
>sure that it's worth doing now.

Agreed. ;-)

Regards,
Wanpeng Li 

>
>Thanks,
>Naoya Horiguchi
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

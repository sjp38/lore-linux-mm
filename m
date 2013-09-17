From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v2 1/4] mm/hwpoison: fix traverse hugetlbfs page
 to avoid printk flood
Date: Tue, 17 Sep 2013 08:08:17 +0800
Message-ID: <307.768668472086$1379376519@news.gmane.org>
References: <1379202839-23939-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20130915001352.GQ18242@two.firstfloor.org>
 <3908561D78D1C84285E8C5FCA982C28F31CFD2D6@ORSMSX106.amr.corp.intel.com>
 <1379369397-ld8lbcn-mutt-n-horiguchi@ah.jp.nec.com>
 <20130916232345.GA3241@hacker.(null)>
 <3908561D78D1C84285E8C5FCA982C28F31CFD50B@ORSMSX106.amr.corp.intel.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1VLiqA-0002oJ-Hf
	for glkm-linux-mm-2@m.gmane.org; Tue, 17 Sep 2013 02:08:26 +0200
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 887BB6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 20:08:24 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 17 Sep 2013 10:08:22 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id D26AC3578050
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 10:08:19 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8GNpn5B3998058
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 09:51:50 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r8H08Ifb021914
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 10:08:18 +1000
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31CFD50B@ORSMSX106.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hi Tony,
On Mon, Sep 16, 2013 at 11:44:32PM +0000, Luck, Tony wrote:
>>>Sorry, I have no meaningful progress on this. Splitting hugepages is not
>>>a trivial operation, and introduce more complexity on hugetlbfs code.
>>>I don't hit on any usecase of it rather than memory failure, so I'm not
>>>sure that it's worth doing now.
>>
>> Agreed. ;-)
>
>Agreed that huge pages should be split - or that it is not worth splitting them?
>

Split hugepages will introduce more complexity and there is no other potential 
users currently as mentioned by Naoya. This patch should be applied as a work 
around before hugetlbfs support splitting. 

>Actually I wonder how useful huge pages still are - transparent huge pages may
>give most of the benefits without having to modify applications to use them.
>Plus the kernel does know how to split them when an error occurs (which I care
>about more than most people).

Transparent huge pages are not helpful for DB workload which there is a lot of 
shared memory, however, transparent huge pages just doing process local memory 
allocation. 

Regards,
Wanpeng Li 

>
>-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

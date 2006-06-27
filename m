Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5RLpWV7004604
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2006 17:51:32 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5RLp08S241872
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2006 15:51:01 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5RLpV4g013347
	for <linux-mm@kvack.org>; Tue, 27 Jun 2006 15:51:32 -0600
Subject: RE: slow hugetlb from 2.6.15
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <000001c69a1f$2171af00$e234030a@amr.corp.intel.com>
References: <000001c69a1f$2171af00$e234030a@amr.corp.intel.com>
Content-Type: text/plain
Date: Tue, 27 Jun 2006 14:51:13 -0700
Message-Id: <1151445073.24103.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Badari Pulavarty' <pbadari@gmail.com>, stanojr@blackhole.websupport.sk, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-27 at 12:23 -0700, Chen, Kenneth W wrote:
>   Though it is a mystery to
> see that faulting on hugetlb page is significantly longer than
> faulting a
> normal page.

There's an awful lot more data to zero when allocating a page which is
1000 times bigger.  It would be really interesting to see kernel
profiles, but my money is on clear_huge_page().

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

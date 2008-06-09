Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id m599U4BR005608
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 19:30:04 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m599UKjB2498724
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 19:30:20 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m599UcRD008382
	for <linux-mm@kvack.org>; Mon, 9 Jun 2008 19:30:39 +1000
Message-ID: <484CF82E.1010508@linux.vnet.ibm.com>
Date: Mon, 09 Jun 2008 15:00:22 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/2] memcg: hierarchy support (v3)
References: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080604135815.498eaf82.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, this is third version.
> 
> While small changes in codes, the whole _tone_ of code is changed.
> I'm not in hurry, any comments are welcome.
> 
> based on 2.6.26-rc2-mm1 + memcg patches in -mm queue.
> 

Hi, Kamezawa-San,

Sorry for the delay in responding. Like we discussed last time, I'd prefer a
shares based approach for hierarchial memcg management. I'll review/try these
patches and provide more feedback.


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2T16N9O028649
	for <linux-mm@kvack.org>; Sat, 29 Mar 2008 12:06:23 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2T16foW4579344
	for <linux-mm@kvack.org>; Sat, 29 Mar 2008 12:06:42 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2T16fAr030965
	for <linux-mm@kvack.org>; Sat, 29 Mar 2008 12:06:41 +1100
Message-ID: <47ED953A.1050906@linux.vnet.ibm.com>
Date: Sat, 29 Mar 2008 06:32:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <6599ad830803280401r68d30e91waaea8eb1de36eb52@mail.gmail.com> <47ECE662.3060506@linux.vnet.ibm.com> <6599ad830803280705o4213c448r991cbf9da6ffe2f1@mail.gmail.com> <47ED0621.4050304@linux.vnet.ibm.com> <6599ad830803280838s19ffc366w1a950ebb12e2907b@mail.gmail.com> <47ED34A4.70604@linux.vnet.ibm.com> <6599ad830803281152g33e693f5s4c7090a503d2751d@mail.gmail.com>
In-Reply-To: <6599ad830803281152g33e693f5s4c7090a503d2751d@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> Hi Balbir,
> 
> Could you send out the latest version of your patch? I suspect it's
> changed a bit based on on this review and it would be good to make
> sure we're both on the same page.

Sure, let me rework that and send it across.

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

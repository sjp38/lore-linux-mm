Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp05.au.ibm.com (8.13.1/8.13.1) with ESMTP id l7MJKIMK013248
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 05:20:18 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MJKFks4177982
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 05:20:16 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MJKFXW029341
	for <linux-mm@kvack.org>; Thu, 23 Aug 2007 05:20:15 +1000
Message-ID: <46CC8C6A.7080904@linux.vnet.ibm.com>
Date: Thu, 23 Aug 2007 00:50:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Memory controller Add Documentation
References: <20070822130612.18981.58696.sendpatchset@balbir-laptop> <6599ad830708221218t3c1eae51o1605f00b8f204b02@mail.gmail.com>
In-Reply-To: <6599ad830708221218t3c1eae51o1605f00b8f204b02@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Containers <containers@lists.osdl.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Dave Hansen <haveblue@us.ibm.com>, Linux MM Mailing List <linux-mm@kvack.org>, Nick Piggin <npiggin@suse.de>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Eric W Biederman <ebiederm@xmission.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 8/22/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  Documentation/memcontrol.txt |  193 +++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 193 insertions(+)
>>
>> diff -puN /dev/null Documentation/memcontrol.txt
>> --- /dev/null   2007-06-01 20:42:04.000000000 +0530
>> +++ linux-2.6.23-rc2-mm2-balbir/Documentation/memcontrol.txt    2007-08-22 18:29:29.000000000 +0530
>> @@ -0,0 +1,193 @@
>> +Memory Controller
>> +
>> +0. Salient features
>> +
>> +a. Enable control of both RSS and Page Cache pages
> 
> s/RSS/anonymous/ (and generally throughout the document)? RSS can
> include pages that are part of the page cache too.
> 
> Paul

Yes, thats a good point. I'll clean up the documentation.


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

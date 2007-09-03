Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id l83Jnito021997
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 05:49:44 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l83JnhnM4448362
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 05:49:43 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l83JnhrY025568
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 05:49:43 +1000
Message-ID: <46DC6543.3000607@linux.vnet.ibm.com>
Date: Mon, 03 Sep 2007 20:49:23 +0100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop> <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com>
In-Reply-To: <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> -       s += sprintf(s, "%lu\n", *val);
>> +       if (read_strategy)
>> +               s += read_strategy(*val, s);
>> +       else
>> +               s += sprintf(s, "%lu\n", *val);
> 
> This would be better as %llu
> 

Hi, Paul,

This does not need fixing, since the other counters like failcnt are
still unsigned long

>> +               tmp = simple_strtoul(buf, &end, 10);
> 
> and this as simple_strtoull()
> 


Will do, thanks!



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

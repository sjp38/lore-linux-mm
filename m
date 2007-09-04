Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l847TJ88021202
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 17:29:19 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l847TJ6I4362242
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 17:29:19 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l847TIKj028965
	for <linux-mm@kvack.org>; Tue, 4 Sep 2007 17:29:18 +1000
Message-ID: <46DD0939.7030409@linux.vnet.ibm.com>
Date: Tue, 04 Sep 2007 08:28:57 +0100
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop> <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com> <46DC6543.3000607@linux.vnet.ibm.com> <6599ad830709040019r17861771we2a0893c0c160723@mail.gmail.com>
In-Reply-To: <6599ad830709040019r17861771we2a0893c0c160723@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 9/3/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Paul Menage wrote:
>>> On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>> -       s += sprintf(s, "%lu\n", *val);
>>>> +       if (read_strategy)
>>>> +               s += read_strategy(*val, s);
>>>> +       else
>>>> +               s += sprintf(s, "%lu\n", *val);
>>> This would be better as %llu
>>>
>> Hi, Paul,
>>
>> This does not need fixing, since the other counters like failcnt are
>> still unsigned long
>>
> 
> But val is an unsigned long long*. So printing *val with %lu will
> break (at least a warning, and maybe corruption if you had other
> parameters) on 32-bit archs.
> 

Yeah... Hmm.. just wonder if all the counters should be unsigned long
long? failcnt is the only remaining unsigned long counter now.

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

Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l66LkjXF273844
	for <linux-mm@kvack.org>; Sat, 7 Jul 2007 07:46:45 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l66LRihe127358
	for <linux-mm@kvack.org>; Sat, 7 Jul 2007 07:27:44 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l66LOCEi028696
	for <linux-mm@kvack.org>; Sat, 7 Jul 2007 07:24:12 +1000
Message-ID: <468EB2F0.8040903@linux.vnet.ibm.com>
Date: Fri, 06 Jul 2007 14:24:00 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm PATCH 1/8] Memory controller resource counters (v2)
References: <20070706052029.11677.16964.sendpatchset@balbir-laptop> <20070706052043.11677.56208.sendpatchset@balbir-laptop> <1183742642.10287.151.camel@localhost>  <468EAE3E.4050802@linux.vnet.ibm.com> <1183756205.10287.212.camel@localhost>
In-Reply-To: <1183756205.10287.212.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, Eric W Biederman <ebiederm@xmission.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Fri, 2007-07-06 at 14:03 -0700, Balbir Singh wrote:
>>>> +ssize_t res_counter_read(struct res_counter *cnt, int member,
>>>> +            const char __user *userbuf, size_t nbytes, loff_t
>> *pos)
>>>> +{
>>>> +    unsigned long *val;
>>>> +    char buf[64], *s;
>>>> +
>>>> +    s = buf;
>>>> +    val = res_counter_member(cnt, member);
>>>> +    s += sprintf(s, "%lu\n", *val);
>>>> +    return simple_read_from_buffer((void __user *)userbuf, nbytes,
>>>> +                    pos, buf, s - buf);
>>>> +}
>>> Why do we need that cast?  
>>>
>> u mean the __user? If I remember correctly it's a attribute for
>> sparse.
> 
> The userbuf is already __user.  This just appears to be making a 'const
> char *' into a 'void *'.  I wondered what the reason for that part is.
> 

Aah.. yes.. good point. I'll look into it.

> -- Dave
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


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

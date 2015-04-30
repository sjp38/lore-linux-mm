Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id E5EF66B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 21:44:58 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so44986480pdb.0
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 18:44:58 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ce1si1102023pbc.144.2015.04.29.18.38.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Apr 2015 18:44:58 -0700 (PDT)
Message-ID: <55418586.2080100@huawei.com>
Date: Thu, 30 Apr 2015 09:29:42 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: Why task_struct slab can't be released back to buddy system?
References: <55408462.6010703@huawei.com> <87fv7j9p6f.fsf@rasmusvillemoes.dk>
In-Reply-To: <87fv7j9p6f.fsf@rasmusvillemoes.dk>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: David Rientjes <rientjes@google.com>, dave.hansen@linux.intel.com, Linux MM <linux-mm@kvack.org>, qiuxishi@huawei.com

On 2015/4/29 18:58, Rasmus Villemoes wrote:
> On Wed, Apr 29 2015, Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:
> 
>> Hi,
>>
>> Our x86 system has crashed because oom.
>> We found task_struct slabs ate much memory.
> 
> I can't explain what you've seen, but a simple way to reduce the
> memory footprint of struct task_struct is
> 
> CONFIG_LATENCYTOP=n
> 
> That will reduce sizeof(struct task_struct) by ~3840 bytes (60%, give or
> take).
> 
Thank you for your sugesstion.

But my purpose is not to reduce sizeof(struct task_struct).
I want to know why the task_struct slab can't be released back
to buddy when the page's inuse is 0.

Best regards!
> Rasmus
> 
>> CACHE    	  NAME                 OBJSIZE  ALLOCATED     TOTAL  SLABS  SSIZE          //**Slabs is much larger than alloctated object counts**
>> ffff88081e007500 task_struct             6528       4639    229775  45955    32k
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 06FEE6B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 21:38:12 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so7566713pab.36
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 18:38:12 -0700 (PDT)
Message-ID: <523903C0.6000609@asianux.com>
Date: Wed, 18 Sep 2013 09:37:04 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com> <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com> <5232773E.8090007@asianux.com> <5233424A.2050704@gmail.com> <5236732C.5060804@asianux.com> <52372EEF.7050608@gmail.com> <5237ABF3.4010109@asianux.com> <alpine.DEB.2.02.1309171552141.21696@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1309171552141.21696@chino.kir.corp.google.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 09/18/2013 06:53 AM, David Rientjes wrote:
> On Tue, 17 Sep 2013, Chen Gang wrote:
> 
>>> BUG_ON() is safe. but I still don't like it. As far as I heard, Google
>>> changes BUG_ON as nop. So, BUG_ON(mpol_to_str() < 0) breaks google.
>>> Please treat an assertion as assertion. Not any other something.
>>>
> 
> Google does not disable BUG_ON(), sheesh.
> 

That sounds a good news.

>> Hmm... in kernel wide, BUG_ON() is 'common' 'standard' assertion, and
>> "mm/" is a common sub-system (not architecture specific), so when we
>> use BUG_ON(), we already 'express' our 'opinion' enough to readers.
>>
> 
> That's ridiculous, we're not going to panic the kernel at runtime because 
> a buffer is too small.  Make it a compile-time error like I suggested so 
> we catch this before we even build the kernel.
> 

It seems not quite polite?  ;-)


BUG_ON() is widely and commonly used in kernel wide, and BUG_ON() can be
customized by any architectures, so I guess, if google really think it
is necessary, it will customize it.

If "compile-time error" will make code complex to both readers and
writers (e.g. our case), forcing "compile-time error" may still be good
enough to google, but may not be good enough for others.

So in my opinion, for our case which is a common sub-system, not an
architecture specific sub-system, better use "run-time error".


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

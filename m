Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 781F16B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 18:53:27 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id p10so6204714pdj.4
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:53:27 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id ld10so7380373pab.8
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:53:24 -0700 (PDT)
Date: Tue, 17 Sep 2013 15:53:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <5237ABF3.4010109@asianux.com>
Message-ID: <alpine.DEB.2.02.1309171552141.21696@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com>
 <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com> <5232773E.8090007@asianux.com> <5233424A.2050704@gmail.com> <5236732C.5060804@asianux.com> <52372EEF.7050608@gmail.com>
 <5237ABF3.4010109@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Tue, 17 Sep 2013, Chen Gang wrote:

> > BUG_ON() is safe. but I still don't like it. As far as I heard, Google
> > changes BUG_ON as nop. So, BUG_ON(mpol_to_str() < 0) breaks google.
> > Please treat an assertion as assertion. Not any other something.
> > 

Google does not disable BUG_ON(), sheesh.

> Hmm... in kernel wide, BUG_ON() is 'common' 'standard' assertion, and
> "mm/" is a common sub-system (not architecture specific), so when we
> use BUG_ON(), we already 'express' our 'opinion' enough to readers.
> 

That's ridiculous, we're not going to panic the kernel at runtime because 
a buffer is too small.  Make it a compile-time error like I suggested so 
we catch this before we even build the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

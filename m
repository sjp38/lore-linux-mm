Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 92B626B0032
	for <linux-mm@kvack.org>; Wed, 18 Sep 2013 18:17:28 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so7639125pde.37
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 15:17:28 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id x10so7670497pdj.29
        for <linux-mm@kvack.org>; Wed, 18 Sep 2013 15:17:25 -0700 (PDT)
Date: Wed, 18 Sep 2013 15:17:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <523903C0.6000609@asianux.com>
Message-ID: <alpine.DEB.2.02.1309181513180.2375@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com>
 <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com> <523205A0.1000102@gmail.com> <5232773E.8090007@asianux.com> <5233424A.2050704@gmail.com> <5236732C.5060804@asianux.com> <52372EEF.7050608@gmail.com>
 <5237ABF3.4010109@asianux.com> <alpine.DEB.2.02.1309171552141.21696@chino.kir.corp.google.com> <523903C0.6000609@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Wed, 18 Sep 2013, Chen Gang wrote:

> BUG_ON() is widely and commonly used in kernel wide, and BUG_ON() can be
> customized by any architectures, so I guess, if google really think it
> is necessary, it will customize it.
> 
> If "compile-time error" will make code complex to both readers and
> writers (e.g. our case), forcing "compile-time error" may still be good
> enough to google, but may not be good enough for others.
> 

Google has nothing to do with this, it treats BUG_ON() just like 99.99% of 
others do.

> So in my opinion, for our case which is a common sub-system, not an
> architecture specific sub-system, better use "run-time error".
> 

That's absolutely insane.  If code is not allocating enough memory for the 
maximum possible length of a string to be stored by mpol_to_str(), it's a 
bug in the code.  We do not panic and reboot the user's machine for such a 
bug.  Instead, we break the build and require the broken code to be fixed.

I have told you exactly how to introduce such a compile-time error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

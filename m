Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id 718946B0032
	for <linux-mm@kvack.org>; Tue, 17 Sep 2013 18:52:02 -0400 (EDT)
Received: by mail-pb0-f48.google.com with SMTP id ma3so6152992pbc.21
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:52:02 -0700 (PDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so7487175pad.0
        for <linux-mm@kvack.org>; Tue, 17 Sep 2013 15:51:59 -0700 (PDT)
Date: Tue, 17 Sep 2013 15:51:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <5237A615.5050405@asianux.com>
Message-ID: <alpine.DEB.2.02.1309171549140.21696@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com>
 <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com> <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com> <5233CF32.3080409@jp.fujitsu.com> <52367AB0.9000805@asianux.com> <alpine.DEB.2.02.1309161309490.26194@chino.kir.corp.google.com>
 <5237A615.5050405@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kosaki.motohiro@gmail.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Tue, 17 Sep 2013, Chen Gang wrote:

> > Rename mpol_to_str() to __mpol_to_str().  Make a static inline function in 
> > mempolicy.h named mpol_to_str().  That function does BUILD_BUG_ON(maxlen < 
> > 64) and then calls __mpol_to_str().
> > 
> > Modify __mpol_to_str() to store "unknown" when mpol->mode does not match 
> > any known MPOL_* constant.
> > 
> 
> Can we be sure 'maxlen' should not be less than 64?  For show_numa_map()
> in fs/proc/task_mmu.c, it use 50 which is less than 64, is it correct?
> 

Whatever the max string length is that can be stored by mpol_to_str() 
preferably rounded to the nearest power of two.

> Can we be sure that our output contents are always less than 64 bytes?
> Do we need BUG_ON() instead of all '-ENOSPC' in mpol_to_str()?
> 

You can determine the maximum string length by looking at the 
implementation of mpol_to_str().

> Hmm... If assume what you said above was always correct: "we are always
> sure 64 bytes is enough, and 'maxlen' should be never less than 64".
> 
>   It would be better to use a structure (which has a member "char buf[64]") pointer instead of 'buffer' and 'maxlen'.
>    (and also still need check 64 memory bondary and '\0' within mpol_to_str).
> 

That's ridiculous, kernel developers who call mpol_to_str() aren't idiots.

I think at this point it will just be best if I propose a patch and ask 
for it to be merged into the -mm tree rather than continue this thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

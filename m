Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 75E6A6B0031
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 16:13:50 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id jt11so4550918pbb.10
        for <linux-mm@kvack.org>; Mon, 16 Sep 2013 13:13:49 -0700 (PDT)
Date: Mon, 16 Sep 2013 13:13:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <52367AB0.9000805@asianux.com>
Message-ID: <alpine.DEB.2.02.1309161309490.26194@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com>
 <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <523124B7.8070408@gmail.com> <alpine.DEB.2.02.1309131410290.31480@chino.kir.corp.google.com> <5233CF32.3080409@jp.fujitsu.com> <52367AB0.9000805@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kosaki.motohiro@gmail.com, riel@redhat.com, hughd@google.com, xemul@parallels.com, liwanp@linux.vnet.ibm.com, gorcunov@gmail.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Mon, 16 Sep 2013, Chen Gang wrote:

> Hmm... I am not quite sure: a C compiler is clever enough to know about
> that.
> 
> At least, for ANSI C definition, the C compiler has no duty to know
> about that.
> 
> And it is not for an optimization, either, so I guess the C compiler has
> no enought interests to support this features (know about that).
> 

What on earth are we talking about in this thread?

Rename mpol_to_str() to __mpol_to_str().  Make a static inline function in 
mempolicy.h named mpol_to_str().  That function does BUILD_BUG_ON(maxlen < 
64) and then calls __mpol_to_str().

Modify __mpol_to_str() to store "unknown" when mpol->mode does not match 
any known MPOL_* constant.

Both functions can now return void.

This is like a ten line diff.  Seriously.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id EF8396B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 17:14:16 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id kp13so3004208pab.21
        for <linux-mm@kvack.org>; Fri, 13 Sep 2013 14:14:16 -0700 (PDT)
Date: Fri, 13 Sep 2013 14:14:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <52312EC1.8080300@asianux.com>
Message-ID: <alpine.DEB.2.02.1309131413130.31480@chino.kir.corp.google.com>
References: <5215639D.1080202@asianux.com> <5227CF48.5080700@asianux.com> <alpine.DEB.2.02.1309091326210.16291@chino.kir.corp.google.com> <522E6C14.7060006@asianux.com> <alpine.DEB.2.02.1309092334570.20625@chino.kir.corp.google.com> <522EC3D1.4010806@asianux.com>
 <alpine.DEB.2.02.1309111725290.22242@chino.kir.corp.google.com> <52312EC1.8080300@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 12 Sep 2013, Chen Gang wrote:

> Hmm... for extern function, at present, maybe you can guarantee, but may
> not always in the future. And "Code is mainly for making readers 'happy'
> (e.g version mergers), not writers".
> 
> For extern function which more than 50 lines (used by 2 sub-systems), it
> is strange for readers to find it no return value, also strange to let
> *BUG_ON() on the extern function's input parameters directly.
> 
> If one caller wants to treat failure as BUG, can "*BUG_ON(mpol_to_str()
> < 0)", that will be more clearer to all members (need this patch do like
> it? :-) ).
> 
> 
> BTW: in my opinion, within mpol_to_str(), the VM_BUG_ON() need be
> replaced by returning -EINVAL.
> 

Are you reading my emails?

I'm asking for a compile-time error if the maxlen passed to mpol_to_str() 
is too small; it's a constant value and can be evaluated at compile-time.  
Then mpol_to_str() can return void if you simply store "unknown" when it's 
an unknown mode.

Sheesh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

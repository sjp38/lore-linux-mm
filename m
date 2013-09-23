Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id CD44E6B0031
	for <linux-mm@kvack.org>; Mon, 23 Sep 2013 17:46:25 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id e14so7233934iej.24
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 14:46:25 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id kl14so2817965pab.11
        for <linux-mm@kvack.org>; Mon, 23 Sep 2013 14:46:22 -0700 (PDT)
Date: Mon, 23 Sep 2013 14:46:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/shmem.c: check the return value of mpol_to_str()
In-Reply-To: <20130919003142.B72EC1840296@intranet.asianux.com>
Message-ID: <alpine.DEB.2.02.1309231439360.11167@chino.kir.corp.google.com>
References: <20130919003142.B72EC1840296@intranet.asianux.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="531381512-1670063046-1379972773=:11167"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Chen=2CGang=28_=E9=99=88=E5=88=9A=29?= <gang.chen@asianux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, hughd@google.com, xemul@parallels.com, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--531381512-1670063046-1379972773=:11167
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT

On Thu, 19 Sep 2013, Chen,Gang( e??a??) wrote:

> PleaseA searchA BUG_ON()A inA kernelA wideA sourceA code,A weA canA knowA whether
> itA isA commonlyA usedA orA not.
> 
> PleaseA searchA BUGA inA arch/A sub-system,A weA canA knowA whichA architectures
> customizeA BUG/BUG_ON.
> 
> AfterA doA theA 2A things,A InA myA opinion,A weA canA treatA BUG/BUG_ON()A isA common
> implementation,A andA mostA ofA architecturesA usesA theA defaultA one.
> 
> PleaseA checkA again,A thanks.
> 

BUG_ON() is used for fatal conditions where continuing could potentially 
be harmful.  Obviously it is commonly used in a kernel.  That doesn't mean 
we BUG_ON() when a string hasn't been defined for a mempolicy mode.  
mpol_to_str() is not critical.

It is not a fatal condition, and nothing you say is going to convince 
anybody on this thread that it's a fatal condition.

> >A That'sA absolutelyA insane.A A IfA codeA isA notA allocatingA enoughA memoryA forA theA 
> >A maximumA possibleA lengthA ofA aA stringA toA beA storedA byA mpol_to_str(),A it'sA aA 
> >A bugA inA theA code.A A WeA doA notA panicA andA rebootA theA user'sA machineA forA suchA aA 
> >A bug.A A Instead,A weA breakA theA buildA andA requireA theA brokenA codeA toA beA fixed.
> >A 
> 
> PleaseA sayA inA polite.
> 

You want a polite response when you're insisting that we declare absolute 
failure, BUG_ON(), stop, and reboot the kernel because a mempolicy mode 
isn't defined as a string in mpol_to_str()?  That sounds like an impolite 
response to the user, so see my politeness to you as coming from the users 
of the systems you just crashed.

This is a compile-time problem, not run-time.

> CanA youA beA sure,A theA "maxlenA ==A 50"A inA "fs/proc/task_mmu()",A mustA beA aA bug??
> 

I asked you to figure out the longest string possible to be stored by 
mpol_to_str().  There's nothing mysterious about that function.  It's 
deterministic.  If you really can't figure out the value this should be, 
then you shouldn't be touching mpol_to_str().
--531381512-1670063046-1379972773=:11167--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

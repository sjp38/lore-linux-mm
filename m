Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id E9D046B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 10:58:28 -0400 (EDT)
Date: Thu, 26 Apr 2012 09:58:26 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
In-Reply-To: <alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1204260956010.16059@router.home>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com> <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
 <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com> <alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <alpine.DEB.2.00.1204260956012.16059@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 6 Mar 2012, David Rientjes wrote:

> That's not compiled for CONFIG_BUG=n; such a config fallsback to
> include/asm-generic/bug.h which just does
>
> 	#define BUG()	do {} while (0)
>
> because CONFIG_BUG specifically _wants_ to bypass BUG()s and is reasonably
> protected by CONFIG_EXPERT.

Why would anyone do this? IMHO if you disable CONFIG_BUG and things
explode then its your fault.

If we must have the ability then make BUG() fallback to something that
quiets down the compiler (and set some kind of an "idiot" flag in the
tainted flags please so that we can ignore bug reports like that).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

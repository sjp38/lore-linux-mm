Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 2C82B6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 16:06:34 -0500 (EST)
Received: by iajr24 with SMTP id r24so11955131iaj.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 13:06:33 -0800 (PST)
Date: Wed, 7 Mar 2012 13:06:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
In-Reply-To: <4F578BCA.1090706@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1203071304160.7640@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com> <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
 <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com> <alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com> <4F570168.6050008@gmail.com> <alpine.DEB.2.00.1203062253150.1427@chino.kir.corp.google.com>
 <4F578BCA.1090706@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: kosaki.motohiro@gmail.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org

On Wed, 7 Mar 2012, KOSAKI Motohiro wrote:

> > It's a different topic, the proposal here is whether an error in 
> > mempolicies (either the code or flipped bit) should crash the kernel or 
> > not since it's a condition that can easily be recovered from and leave 
> > BUG() to errors that actually are fatal.  Crashing the kernel offers no 
> > advantage.
> 
> Should crash? The code path never reach. thus there is no ideal behavior.
> In this case, BUG() is just unreachable annotation. So let's just annotate
> unreachable() even though CONFIG_BUG=n.
> 
> WARN_ON_ONCE makes code broat and no positive impact.
> 

I think you misunderstand the difference between WARN() and BUG().  Both 
are intended to never be reached; the difference is that BUG() is a fatal 
condition and WARN() is not.  All of the changes from BUG() to WARN() in 
this patch are not fatal and has no other side-effects other memory 
allocations that are not truly interleaved, for example.  These should 
have been WARN() from the beginning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

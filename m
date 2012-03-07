Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id C0DC06B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 01:56:39 -0500 (EST)
Received: by iajr24 with SMTP id r24so10683652iaj.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 22:56:39 -0800 (PST)
Date: Tue, 6 Mar 2012 22:56:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, mempolicy: make mempolicies robust against errors
In-Reply-To: <4F570168.6050008@gmail.com>
Message-ID: <alpine.DEB.2.00.1203062253150.1427@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203041341340.9534@chino.kir.corp.google.com> <20120306160833.0e9bf50a.akpm@linux-foundation.org> <alpine.DEB.2.00.1203061950050.24600@chino.kir.corp.google.com> <alpine.DEB.2.00.1203062025490.24600@chino.kir.corp.google.com>
 <CAHGf_=qG1Lah00fGTNENvtgacsUt1=FcMKyt+kmPG1=UD6ecNw@mail.gmail.com> <alpine.DEB.2.00.1203062151530.6424@chino.kir.corp.google.com> <4F570168.6050008@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

On Wed, 7 Mar 2012, KOSAKI Motohiro wrote:

> So, I strongly suggest to remove CONFIG_BUG=n. It is neglected very long time
> and
> much plenty code assume BUG() is not no-op. I don't think we can fix all
> place.
> 
> Just one instruction don't hurt code size nor performance.
> 

It's a different topic, the proposal here is whether an error in 
mempolicies (either the code or flipped bit) should crash the kernel or 
not since it's a condition that can easily be recovered from and leave 
BUG() to errors that actually are fatal.  Crashing the kernel offers no 
advantage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

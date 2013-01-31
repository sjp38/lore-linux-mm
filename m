Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id E853D6B0005
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 18:07:41 -0500 (EST)
Date: Fri, 1 Feb 2013 10:06:55 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301312306.r0VN6tBx012280@como.maths.usyd.edu.au>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <1359639529.31386.49.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 695182@bugs.debian.org, ben@decadent.org.uk
Cc: dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@ucw.cz

Dear Ben,

> Based on your experience I might propose to change the automatic kernel
> selection for i386 so that we use 'amd64' on a system with >16GB RAM and
> a capable processor.

Don't you mean change to amd64 for >4GB (or any RAM), never using PAE?
PAE is broken for any amount of RAM. More precisely, PAE with any RAM
fails the "sleep test":
  n=0; while [ $n -lt 33000 ]; do sleep 600 & ((n=n+1)); done
and with >32GB fails the "write test":
  n=0; while [ $n -lt 99 ]; do dd bs=1M count=1024 if=/dev/zero of=x$n; ((n=n+1)); done
Why do you think 16GB is significant?

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

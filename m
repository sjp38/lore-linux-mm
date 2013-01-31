Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id CC3436B0007
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 04:07:34 -0500 (EST)
Date: Thu, 31 Jan 2013 20:07:04 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301310907.r0V974j9017335@como.maths.usyd.edu.au>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <1359609334.31386.40.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 695182@bugs.debian.org, ben@decadent.org.uk
Cc: dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@ucw.cz

Dear Ben,

Thanks for the repeated explanations.

> PAE was a stop-gap ...
> ... [PAE] completely untenable.

Is this a good time to withdraw PAE, to tell the world that it does not
work? Maybe you should have had such comments in the code.

Seems that amd64 now works "somewhat": on Debian the linux-image package
is tricky to install, and linux-headers is even harder. Is there work
being done to make this smoother?

---

I am still not convinced by the "lowmem starvation" explanation: because
then PAE should have worked fine on my 3GB machine; maybe I should also
try PAE on my 512MB laptop. - Though, what do I know, have not yet found
the buggy line of code I believe is lurking there...

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

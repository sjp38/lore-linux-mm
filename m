Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id A47656B002B
	for <linux-mm@kvack.org>; Thu, 31 Jan 2013 22:13:42 -0500 (EST)
Date: Fri, 1 Feb 2013 14:13:29 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201302010313.r113DTj3027195@como.maths.usyd.edu.au>
Subject: Re: Bug#695182: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <1359687434.31386.53.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ben@decadent.org.uk
Cc: 695182@bugs.debian.org, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pavel@ucw.cz

Dear Ben,

>>>> PAE is broken for any amount of RAM.
>>> No it isn't.
>> Could I please ask you to expand on that?
>
> I already did, a few messages back.

OK, thanks. Noting however that fewer than those back, I said:
  ... PAE with any RAM fails the "sleep test":
  n=0; while [ $n -lt 33000 ]; do sleep 600 & ((n=n+1)); done
and somewhere also said that non-PAE passes. Does not that prove
that PAE is broken?

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

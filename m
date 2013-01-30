Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 75D116B0007
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 14:48:45 -0500 (EST)
Date: Thu, 31 Jan 2013 06:40:14 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301301940.r0UJeEKa016044@como.maths.usyd.edu.au>
Subject: Re: [RFC] Reproducible OOM with just a few sleeps
In-Reply-To: <51093D03.8070006@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave@linux.vnet.ibm.com, pavel@ucw.cz
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Pavel and Dave,

> The assertion was that 4GB with no PAE passed a forkbomb test (ooming)
> while 4GB of RAM with PAE hung, thus _PAE_ is broken.

Yes, PAE is broken. Still, maybe the above needs slight correction:
non-PAE HIGHMEM4G passed the "sleep test": no OOM, nothing unexpected;
whereas PAE OOMed then hung (tested with various RAM from 3GB to 64GB).

The feeling I get is that amd64 is proposed as a drop-in replacement for
PAE, that support and development of PAE is gone, that PAE is dead.

Cheers, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

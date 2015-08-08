Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id DEC786B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 22:07:47 -0400 (EDT)
Received: by igr7 with SMTP id 7so41482003igr.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 19:07:47 -0700 (PDT)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [2001:558:fe21:29:69:252:207:38])
        by mx.google.com with ESMTPS id p136si9712339iop.54.2015.08.07.19.07.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 19:07:46 -0700 (PDT)
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
References: <55C18D2E.4030009@rjmx.net>
 <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org>
 <20150805162436.GD25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
 <20150805163609.GE25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org>
 <55C2BC00.8020302@rjmx.net>
 <alpine.DEB.2.11.1508052229540.891@east.gentwo.org>
 <55C3F70E.2050202@rjmx.net> <55C4C6E8.5090501@redhat.com>
From: Ron Murray <rjmx@rjmx.net>
Message-ID: <55C5645D.1080508@rjmx.net>
Date: Fri, 7 Aug 2015 22:07:25 -0400
MIME-Version: 1.0
In-Reply-To: <55C4C6E8.5090501@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>, Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On 08/07/2015 10:55 AM, Laura Abbott wrote:
>
> There was a similar report about a crash on reboot with 4.1.3[1]
> where that reporter linked it to a bluetooth mouse. Hopefully this
> isn't a red herring but it might be a similar report?
>
> Thanks,
> Laura
>
> [1]https://bugzilla.redhat.com/show_bug.cgi?id=3D1248741
>
Thanks for the suggestion. I don't have a bluetooth mouse (although it
is wireless), but I do have a bluetooth keyboard. And -- surprise! -- I
don't get a crash when I leave the keyboard turned off.

It seems to me that there are at least two possibilities here:

1. Something in the bluetooth stack causes some kind of memory corruption=


or

2. The corruption is caused by something else, and using bluetooth
shifts it into a memory range where it causes crashes (we already know
that it's very touchy).

Do you know if the original poster in the Red Hat bug report solved the
problem, or did he just give up using bluetooth?

Suggestions for further faultfinding appreciated.

 .....Ron


--=20
Ron Murray <rjmx@rjmx.net>
PGP Fingerprint: 0ED0 C1D1 615C FCCE 7424  9B27 31D8 AED5 AF6D 0D4A


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

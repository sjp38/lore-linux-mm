Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id AF41A6B0253
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 21:44:47 -0400 (EDT)
Received: by igk11 with SMTP id 11so2443345igk.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 18:44:47 -0700 (PDT)
Received: from resqmta-po-06v.sys.comcast.net (resqmta-po-06v.sys.comcast.net. [2001:558:fe16:19:96:114:154:165])
        by mx.google.com with ESMTPS id a18si347114igr.7.2015.08.05.18.44.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 18:44:43 -0700 (PDT)
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
References: <55C18D2E.4030009@rjmx.net>
 <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org>
 <20150805162436.GD25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051131580.29823@east.gentwo.org>
 <20150805163609.GE25159@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org>
From: Ron Murray <rjmx@rjmx.net>
Message-ID: <55C2BC00.8020302@rjmx.net>
Date: Wed, 5 Aug 2015 21:44:32 -0400
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.11.1508051201280.29823@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>

On 08/05/2015 01:01 PM, Christoph Lameter wrote:
> On Wed, 5 Aug 2015, Peter Zijlstra wrote:
>
>> On Wed, Aug 05, 2015 at 11:32:31AM -0500, Christoph Lameter wrote:
>>> On Wed, 5 Aug 2015, Peter Zijlstra wrote:
>>>
>>>> I'll go have a look; but the obvious question is, what's the last kn=
own
>>>> good kernel?
>>> 4.0.9 according to the original report.
>> Weird, there have been no changes to this area in v4.0..v4.1.
> Rerunning this with "slub_debug" may reveal additional info. Maybe ther=
e
> is some data corrupting going on.
>
OK, tried that (with no parameters though. Should I try some?). That got
me a crash with a blank screen and no panic report. The thing is clearly
touchy: small changes in memory positions make a difference. That's
probably why I didn't get a panic message until 4.1.4: the gods have to
all be looking in the right direction.

One thing I did notice on the original report, though:

> [  OK  ] Deactivated swap /dev/dm-1.
> [  OK  ] Stopped ACPI event daemon.
> [  OK  ] Stopped LSB: Starts the GNUnet server at boot time..
> [  OK  ] Stopped LSB: start Samba SMB/CIFS daemon (smbd).
> [  OK  ] Stopped LSB: start Samba daemons for the AD DC.
>          Stopping CUPS Scheduler...
>          Stopping LSB: start Samba NetBIOS nameserver (nmbd)...
> [  OK  ] Stopped CUPS Scheduler.
> [  OK  ] Stopped (null).
> ------------[ cut here ]------------

Note the "Stopped (null)" before the "cut here" line. I wonder whether
that has anything to do with the problem, or is it a red herring?

 .....Ron

--=20
Ron Murray <rjmx@rjmx.net>
PGP Fingerprint: 0ED0 C1D1 615C FCCE 7424  9B27 31D8 AED5 AF6D 0D4A


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

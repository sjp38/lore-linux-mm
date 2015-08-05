Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id CFD4D6B0255
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 17:30:22 -0400 (EDT)
Received: by ykeo23 with SMTP id o23so46793294yke.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 14:30:22 -0700 (PDT)
Received: from resqmta-ch2-04v.sys.comcast.net (resqmta-ch2-04v.sys.comcast.net. [2001:558:fe21:29:69:252:207:36])
        by mx.google.com with ESMTPS id u18si7853264qgd.7.2015.08.05.14.30.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 14:30:21 -0700 (PDT)
References: <55C18D2E.4030009@rjmx.net> <alpine.DEB.2.11.1508051105070.29534@east.gentwo.org> <20150805162436.GD25159@twins.programming.kicks-ass.net> <81C750EC-F4D4-4890-894A-1D92E5CF3A31@rjmx.net> <alpine.DEB.2.11.1508051405130.30653@east.gentwo.org> <12261B75-F5F5-4332-A7E9-490251E4DC37@rjmx.net> <alpine.DEB.2.11.1508051431570.30889@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1508051431570.30889@east.gentwo.org>
Mime-Version: 1.0 (1.0)
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <86F8E462-6302-41BE-9271-CA150A822F3A@rjmx.net>
From: Ron Murray <rjmx@rjmx.net>
Subject: Re: PROBLEM: 4.1.4 -- Kernel Panic on shutdown
Date: Wed, 5 Aug 2015 17:30:04 -0400
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@redhat.com>


> On Aug 5, 2015, at 15:34, Christoph Lameter <cl@linux.com> wrote:
> 
>> On Wed, 5 Aug 2015, Ron Murray wrote:
>> 
>> True. But if I don't get a crash with it, it might tell us whether the
>> fault lies with SLUB or not. And I will still try with SLUB and the
>> debug option (probably tonight, after I get home).
> 
> What fails is the check for a pointer to valid slab page on kfree. That
> pointer was handed to the allocator.
> 

Fair enough. I'll go with the command-line option instead.

--
Ron Murray <rjmx@rjmx.net>
PGP Fingerprint: 0ED0 C1D1 615C FCCE 7424  9B27 31D8 AED5 AF6D 0D4A

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

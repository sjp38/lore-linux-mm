Date: Fri, 20 Jun 2008 12:39:21 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] - Fix stack overflow for large values of MAX_APICS
Message-ID: <20080620103921.GC32500@elte.hu>
References: <20080620025104.GA25571@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080620025104.GA25571@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> physid_mask_of_physid() causes a huge stack (12k) to be created if the 
> number of APICS is large. Replace physid_mask_of_physid() with a new 
> function that does not create large stacks. This is a problem only on 
> large x86_64 systems.

this indeed fixes the crash i reported here:

   http://lkml.org/lkml/2008/6/19/98

so i've added both this and the MAXAPICS patch to tip/x86/uv, and will 
test it some more. Lets hope it goes all well this time :-)

btw., it would be nice to have an ftrace plugin that prints out the 
worst-case stack footprint and generates an assert if we overflow the 
stack. -rt's kernel/latency_trace.c used to have that feature. That way 
incidents like this would be detected on the spot by -tip's 
auto-testing. The code in question is in kernel/trace/ftrace.c (and 
other nearby code).

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

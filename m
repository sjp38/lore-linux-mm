Message-ID: <40048.81.207.0.53.1155405282.squirrel@81.207.0.53>
In-Reply-To: <1155404697.13508.81.camel@lappy>
References: <20060812141415.30842.78695.sendpatchset@lappy>
    <20060812141445.30842.47336.sendpatchset@lappy>
    <44640.81.207.0.53.1155403862.squirrel@81.207.0.53>
    <1155404697.13508.81.camel@lappy>
Date: Sat, 12 Aug 2006 19:54:42 +0200 (CEST)
Subject: Re: [RFC][PATCH 3/4] deadlock prevention core
From: "Indan Zupancic" <indan@nul.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Evgeniy Polyakov <johnpol@2ka.mipt.ru>, Daniel Phillips <phillips@google.com>, Rik van Riel <riel@redhat.com>, David Miller <davem@davemloft.net>
List-ID: <linux-mm.kvack.org>

On Sat, August 12, 2006 19:44, Peter Zijlstra said:
> Euhm, right :-) long comes naturaly when I think about quantities op
> pages. The adjust_memalloc_reserve() argument is an increment, a delta;
> perhaps I should change that to long.

Maybe, but having 16 TB of reserved memory seems plenty for a while.

> Having them separate would allow ajust_memalloc_reserve() to be used by
> other callers too (would need some extra locking).

True, but currently memalloc_reserve isn't used in a sensible way,
or I'm missing something.

Greetings,

Indan


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

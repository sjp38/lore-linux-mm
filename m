Subject: memory pressure and kswapd
Message-ID: <OF84F4052E.D0DA6D69-ON88256963.005F5758@LocalDomain>
From: "Ying Chen/Almaden/IBM" <ying@almaden.ibm.com>
Date: Sat, 23 Sep 2000 10:31:04 -0700
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I have a question on the memory_pressure() and keep_kswapd_awake() calls.
The question may be specific to test6, since vm has been changed in more
recently releases.
Why should memory_pressure() and keep_kswapd_awake() return 1 as long as
one of the zones is low on memory? Shouldn't it be the case that when all
of the zones are low then return 1? I noticed that in some cases, when I
ran out of memory in DMA and low memory zones, kswapd would kick in and is
kept awake for ever, despite the fact that I still have about 1GB memory in
the HIGH memory zone. At least I'd think that for NORMAL memory
allocations, they should be able to use both LOW and HIGH memory zones, and
only kick kswapd when both LOW and HIGH zones are short of memory.
Am I missing something here?


Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

Date: Thu, 6 Jan 2000 07:28:19 -0800
Message-Id: <200001061528.HAA05974@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <Pine.LNX.4.10.10001061701160.5892-100000@chiara.csoma.elte.hu>
	(message from Ingo Molnar on Thu, 6 Jan 2000 17:05:41 +0100 (CET))
Subject: Re: [RFC] [RFT] [PATCH] memory zone balancing
References: <Pine.LNX.4.10.10001061701160.5892-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@chiara.csoma.elte.hu
Cc: kanoj@google.engr.sgi.com, andrea@suse.de, torvalds@transmeta.com, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

   i think this is pretty much 'type-dependent'. In earlier versions
   of the zone allocator i added a zone->memory_balanced() function
   (but removed it later because it first needed the things your patch
   adds). Then every zone can decide for itself wether it's
   balanced. Eg. the DMA zone is rather critical and we want to keep
   it free aggressively (part of that is already achieved by placing
   it at the end of the zone chain), the highmem zone might not need
   any balancing at all, the normal zone wants some high/low watermark
   stuff.

Let's be careful not to design any balancing heuristics which will
fall apart on architectures where only one zone ever exists (because
GFP_DMA is completely meaningless).

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/

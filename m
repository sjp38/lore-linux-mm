Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH] mm: tracking shared dirty pages -v10
Date: Fri, 23 Jun 2006 11:27:51 -0700
Message-ID: <14CFC56C96D8554AA0B8969DB825FEA0012B3592@chicken.machinevisionproducts.com>
From: "Brian D. McGrew" <brian@visionpro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>, Martin Bligh <mbligh@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, David Howells <dhowells@redhat.com>, Christoph Lameter <christoph@lameter.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> I had assumed this was a sick joke. Please tell me people aren't
> really swapping over NFS. That's *insane*.

Hey, I think it even used to be common. I think some NCR X client did 
basically exactly that, with _no_ local disk at all.

			Linus

---

Some of us still do!  Ah, the joys of remote clients!!!
(Now that I think about it, I should put those guys back on dial-up)

:b!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Wed, 15 Aug 2001 13:53:12 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: [PATCH]
In-Reply-To: <Pine.LNX.4.33.0108151036350.2407-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.33.0108151349020.31764-100000@touchme.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Linus Torvalds wrote:

> Good catch.

Eeep, on re-reading it, I was wrong: vm_flags only has VM_* in the bits,
so this patch would introduce a bug (oops, I must need coffee).  So, it
must be in the mremap/mprotect related bits.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

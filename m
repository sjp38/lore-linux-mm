Date: Mon, 9 Jul 2001 12:18:38 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [wip-PATCH] Re: Large PAGE_SIZE
In-Reply-To: <Pine.LNX.4.33.0107082224020.30164-100000@toomuch.toronto.redhat.com>
Message-ID: <Pine.LNX.4.21.0107091210570.1187-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 8 Jul 2001, Ben LaHaise wrote:
> 
> Hmmm, interesting.  At present page cache sizes from PAGE_SIZE to
> 8*PAGE_SIZE are working here.  Setting the shift to 4 or a 64KB page size
> results in the SCSI driver blowing up on io completion.

I hit that limit too: I believe it comes from unsigned short b_size.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

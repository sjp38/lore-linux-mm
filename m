Date: Fri, 5 Sep 2003 15:46:21 -0400 (EDT)
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 1/2] remap file pages MAP_NONBLOCK fix
In-Reply-To: <20030905185056.GA3598@gtf.org>
Message-ID: <Pine.LNX.4.44.0309051545190.22540-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>, akpm@osdl.org, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Sep 2003, Jeff Garzik wrote:

> Or we could just kill remap_file_pages(), because it's a PITA to
> maintain and it has maybe 10 legitimate users in the entire world...

It has its uses.  I just don't think it should support
a non-mlocked VMA or deal with files being truncated.

The remap_file_pages we have in Taroon is pretty light
weight. I hope the implementation in 2.6 will be
simplified too ;)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

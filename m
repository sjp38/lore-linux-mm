Date: Sat, 6 Sep 2003 10:36:02 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/2] remap file pages MAP_NONBLOCK fix
In-Reply-To: <202200000.1062791080@flay>
Message-ID: <Pine.LNX.4.56.0309061034240.3396@localhost.localdomain>
References: <Pine.LNX.4.44.0309051545190.22540-100000@chimarrao.boston.redhat.com>
 <202200000.1062791080@flay>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Rik van Riel <riel@redhat.com>, Jeff Garzik <jgarzik@pobox.com>, Rajesh Venkatasubramanian <vrajesh@eecs.umich.edu>, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 5 Sep 2003, Martin J. Bligh wrote:

> >> Or we could just kill remap_file_pages(), because it's a PITA to
> >> maintain and it has maybe 10 legitimate users in the entire world...
> > 
> > It has its uses.  I just don't think it should support
> > a non-mlocked VMA or deal with files being truncated.
> > 
> > The remap_file_pages we have in Taroon is pretty light
> > weight. I hope the implementation in 2.6 will be
> > simplified too ;)
> 
> We did actually agree to do this at Kernel Summit too ....

yep - i did most of the simplification for 2.4 and it worked out well.  
Having fremap a non-swappable thing lessens the impact on the rest of the
VM quite significantly.

	Ingo
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

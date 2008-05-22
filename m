Date: Thu, 22 May 2008 10:47:36 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: 2.6.26: x86/kernel/pci_dma.c: gfp |= __GFP_NORETRY ?
Message-ID: <20080522084736.GC31727@one.firstfloor.org>
References: <20080521113028.GA24632@xs4all.net> <48341A57.1030505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48341A57.1030505@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Glauber Costa <gcosta@redhat.com>
Cc: Miquel van Smoorenburg <miquels@cistron.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, andi-suse@firstfloor.org
List-ID: <linux-mm.kvack.org>

On Wed, May 21, 2008 at 09:49:27AM -0300, Glauber Costa wrote:
> probably andi has a better idea on why it was added, since it used to 
> live in his tree?

d_a_c() tries a couple of zones, and running the oom killer for each
is inconvenient. Especially for the 16MB DMA zone which is unlikely
to be cleared by the OOM killer anyways because normal user applications
don't put pages in there. There was a real report with some problems
in this area. Also for the earlier tries you don't want to really
bring the system into swap.

Mask allocator would clean most of that up.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 10 Oct 2003 11:01:01 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: TLB flush optimization on s/390.
Message-ID: <20031010090101.GD23672@wotan.suse.de>
References: <OFF67143AC.941FD14C-ONC1256DBB.002D6C6B-C1256DBB.002DCC69@de.ibm.com> <20031010015018.7afb5ca0.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20031010015018.7afb5ca0.davem@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "David S. Miller" <davem@redhat.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, willy@debian.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 10, 2003 at 01:50:18AM -0700, David S. Miller wrote:
> On Fri, 10 Oct 2003 10:20:14 +0200
> "Martin Schwidefsky" <schwidefsky@de.ibm.com> wrote:
> 
> > Would you care to explain why this is a problem? It's a static function
> > that gets folded into another static function. I added additional arguments
> > to copy_one_pte and to avoid to make move_one_page slower I though to
> > inline it would be a good idea.
> 
> On at least x86 and sparc it makes it so that GCC cannot allocate
> enough registers and it has to reload several values to the
> stack.
> 
> In general when the functions are huge it never makes sense to
> inline them even if only used in one place.

Also it makes oops much easier to read when the functions are smaller ;-)

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Message-ID: <3B21421D.3CF8A40A@earthlink.net>
Date: Fri, 08 Jun 2001 15:22:37 -0600
From: "Joseph A. Knapka" <jknapka@earthlink.net>
MIME-Version: 1.0
Subject: Re: temp. mem mappings
References: <3B2DF994@MailAndNews.com> <20010608190717.T1757@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: cohutta <cohutta@MailAndNews.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Thu, Jun 07, 2001 at 09:38:06PM -0400, cohutta wrote:
> 
> > >Right --- you can use alloc_pages but we haven't done the
> > >initialisation of the kmalloc slabsl by this point.
> >
> > My testing indicates that i can't use __get_free_page(GFP_KERNEL)
> > any time during setup_arch() [still x86].  It causes a BUG
> > in slab.c (line 920) [linux 2.4.5].
> 
> After paging_init(), it should be OK --- as long as there is enough
> memory that you don't end up calling the VM try_to_free_page routines.
> Those will definitely choke this early in boot.

But we don't actually give the zone allocator any free pages
until mem_init().

- Joe

-- Joseph A. Knapka
"You know how many remote castles there are along the gorges? You
 can't MOVE for remote castles!" -- Lu Tze re. Uberwald
// Linux MM Documentation in progress:
// http://home.earthlink.net/~jknapka/linux-mm/vmoutline.html
* Evolution is an "unproven theory" in the same sense that gravity is. *
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

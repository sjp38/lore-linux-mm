Date: Fri, 8 Jun 2001 19:07:17 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: temp. mem mappings
Message-ID: <20010608190717.T1757@redhat.com>
References: <3B2DF994@MailAndNews.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3B2DF994@MailAndNews.com>; from cohutta@MailAndNews.com on Thu, Jun 07, 2001 at 09:38:06PM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: cohutta <cohutta@MailAndNews.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 07, 2001 at 09:38:06PM -0400, cohutta wrote:

> >Right --- you can use alloc_pages but we haven't done the
> >initialisation of the kmalloc slabsl by this point.
> 
> My testing indicates that i can't use __get_free_page(GFP_KERNEL)
> any time during setup_arch() [still x86].  It causes a BUG
> in slab.c (line 920) [linux 2.4.5]. 

After paging_init(), it should be OK --- as long as there is enough
memory that you don't end up calling the VM try_to_free_page routines.
Those will definitely choke this early in boot.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

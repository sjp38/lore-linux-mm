Date: Wed, 22 Nov 2000 15:28:14 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: max memory limits ???
Message-ID: <20001122152814.B7417@redhat.com>
References: <3A1BCC05.4080608@SANgate.com> <20001122161104.C28963@mea-ext.zmailer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001122161104.C28963@mea-ext.zmailer.org>; from matti.aarnio@zmailer.org on Wed, Nov 22, 2000 at 04:11:04PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matti Aarnio <matti.aarnio@zmailer.org>
Cc: BenHanokh Gabriel <gabriel@SANgate.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Nov 22, 2000 at 04:11:04PM +0200, Matti Aarnio wrote:
> > - does using HIGHMEM results with performance penalty   ?
> 
> 	Of course, it causes extra mapping operations on machines
> 	needing it to support larger memory (intel PAE36 featured
> 	hardware).  User processes can access all what is mapped
> 	into them at the same time -- All programs, kernel included
> 	are limited to 32 bit addresses, but kernel can juggle maps
> 	to reach areas not mapped in its address space at some moment.

The other performance implications are:

HIGHMEM currently results in extra copies if you are on Intel and
using a 4G or 64G config, whenever you perform disk IO to memory above
1GB.  If you are using the 64G config (PAE36), then the page tables
double in size, occupying more of your cache.  Those are likely to be
the two biggest performance costs in enabling highmem in an i686
kernel.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

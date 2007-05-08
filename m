Date: Tue, 8 May 2007 20:59:33 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: Get FRV to be able to run SLUB
Message-ID: <20070508115933.GA15074@linux-sh.org>
References: <Pine.LNX.4.64.0705072037030.4661@schroedinger.engr.sgi.com> <7950.1178620309@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7950.1178620309@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Howells <dhowells@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, May 08, 2007 at 11:31:49AM +0100, David Howells wrote:
> Christoph Lameter <clameter@sgi.com> wrote:
> Missing header file inclusion.
> 
> > +	pgd = quicklist_free(0, NULL, pgd_dtor);
> 
> That function is void, and is should be passed pgd or something, but I'm not
> sure what.  No other arch seems to use this.
> 
sparc64 uses it now, and others are moving over to it gradually (I just
converted SH earlier). pgd_free() should be:

	quicklist_free(0, pgd_dtor, pgd);

in this case.

include/linux/quicklist.h isn't exactly lacking for documentation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

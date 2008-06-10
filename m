Date: Tue, 10 Jun 2008 05:05:35 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 19/21] powerpc: define support for 16G hugepages
Message-ID: <20080610030535.GF19404@wotan.suse.de>
References: <20080604112939.789444496@amd.local0.net> <20080604113113.399344268@amd.local0.net> <20080608120511.1b04c67a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080608120511.1b04c67a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 08, 2008 at 12:05:11PM -0700, Andrew Morton wrote:
> On Wed, 04 Jun 2008 21:29:58 +1000 npiggin@suse.de wrote:
> 
> > +		switch (HPAGE_SHIFT) {
> > +		case PAGE_SHIFT_64K:
> > +		    /* We only allow 64k hpages with 4k base page,
> > +		     * which was checked above, and always put them
> > +		     * at the PMD */
> > +		    hugepte_shift = PMD_SHIFT;
> > +		    break;
> 
> eww, what's with the tabspacespacespacespace?

Don't think I messed with any of that. There seemed to be some interesting
comment styles in that file, so I resisted the urge to change things.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

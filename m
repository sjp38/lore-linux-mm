Date: Tue, 18 Mar 2008 12:35:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 8/9] Pageflags: Eliminate PG_xxx aliases
In-Reply-To: <84144f020803181232y55a35393id73d2bd78f8d6159@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0803181235220.23920@schroedinger.engr.sgi.com>
References: <20080318181957.138598511@sgi.com>  <20080318182036.212376083@sgi.com>
 <84144f020803181232y55a35393id73d2bd78f8d6159@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jeremy Fitzhardinge <jeremy@goop.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 18 Mar 2008, Pekka Enberg wrote:

> On Tue, Mar 18, 2008 at 8:20 PM, Christoph Lameter <clameter@sgi.com> wrote:
> >   #ifdef CONFIG_HIGHMEM
> >   /*
> >   * Must use a macro here due to header dependency issues. page_zone() is not
> >   * available at this point.
> >   */
> >  -#define PageHighMem(__p) is_highmem(page_zone(page))
> >  +#define PageHighMem(__p) is_highmem(page_zone(__p))
> 
> Looks like this hunk should be in some other patch.

True....
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

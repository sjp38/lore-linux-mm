Date: Thu, 22 Feb 2007 10:45:06 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
In-Reply-To: <6599ad830702220921w71126a5bg2a21a08befce7bec@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0702221044270.2011@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
 <6599ad830702220921w71126a5bg2a21a08befce7bec@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Paul Menage wrote:

> On 2/21/07, Christoph Lameter <clameter@sgi.com> wrote:
> > If the kernel was compiled without support for swapping then we have no
> > means
> > of evicting anonymous pages and they become like mlocked pages.
> 
> How will this interact with page migration?

The same way as mlocked pages are handled.

> In order to start migrating a page, the migration paths call
> isolate_lru_page(), which returns -EBUSY if the page isn't on an LRU.

Not anymore. Check Andrew's tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

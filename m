Date: Tue, 20 Jun 2006 13:49:57 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: zoned-vm-stats-add-nr_anon.patch
In-Reply-To: <44985E9E.1070603@google.com>
Message-ID: <Pine.LNX.4.64.0606201347470.12229@schroedinger.engr.sgi.com>
References: <44985E9E.1070603@google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Bligh <mbligh@google.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Jun 2006, Martin Bligh wrote:

> Could we rename nr_mapped to something else if we're going to change
> it's meaning? Perhaps split nr_mapped into nr_mapped_file and
> nr_mapped_anon or something?

Yes we did that. nr_mapped was split into NR_MAPPED and NR_ANON. Please 
read the description for V4 if this patchset that was posted last week.

> In my mind, "nr_mapped" is a good name for the number of pages which
> are mapped, so excluding the anon pages from that seems to make
> the naming non-obvious. similarly, I presume we can have anon pages
> on transition to or from swap that are not mapped, and yet will
> not be reflected here, so nr_anon doesn't seem like a wholly

The same confusion exist for nr_dirty. Should we also rename nr_dirty to 
nr_dirty_file?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 1 Jul 2003 03:51:34 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.73-mm2
Message-ID: <20030701105134.GE26348@holomorphy.com>
References: <20030701003958.GB20413@holomorphy.com> <Pine.LNX.4.44.0307011137001.1161-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0307011137001.1161-100000@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jun 2003, William Lee Irwin III wrote:
>> It was suggested during my last round of OOM killer fixes that one of
>> my patches, which just checked nr_free_buffer_pages() > 0, should also
>> consider userspace (i.e. reclaimable at will) memory free.

On Tue, Jul 01, 2003 at 11:46:34AM +0100, Hugh Dickins wrote:
> If you pursued it, wouldn't your patch also need to change
> nr_free_buffer_pages() to do what you think it does, count
> the free lowmem pages?  It, and nr_free_pagecache_pages(),
> and nr_free_zone_pages(), are horribly badly named.  They
> count present_pages-pages_high, they don't count free pages:
> okay for initialization estimates, useless for anything dynamic.
> Hugh
> p.s. any chance of some more imaginative Subject lines :-?

Well, I was mostly looking for getting handed back 0 when lowmem is
empty; I actually did realize they didn't give entirely accurate counts
of free lowmem pages.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

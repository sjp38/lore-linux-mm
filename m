Date: Wed, 10 Apr 2002 15:16:16 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre5-ac3
Message-ID: <20020410221616.GA23767@holomorphy.com>
References: <20020407164439.GA5662@debian> <20020410205947.GG21206@holomorphy.com> <20020410220842.GA14573@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020410220842.GA14573@debian>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Art Haas <ahaas@neosoft.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 10, 2002 at 05:08:42PM -0500, Art Haas wrote:
> I think you've dropped an "=". Maybe this is the cause of the
> other trouble you were seeing?
> I hadn't posted it yet, but I've made a newer version of the
> patch that incorporates the latest changes from Christoph Hellwig
> and Andrew Morton - the changes of spin_lock() and spin_unlock()
> to (read|write)_lock() and (read|write)_unlock, plus a few cosmetic
> changes. I'm running a kernel with those changes right now (and things
> work for me, but we've seen how that goes ...) . I'll rebuild my kernel
> with your fix to the swap_state.c file and see how that kernel
> performs. I can cook up a script to repeatedly build something and
> let things run for a while. If it works I'll post my modified patch tomorrow.
> Thanks again for the feedback!

I did, you will need the == sorry.

I've been running Cerberus with this on a logical 8-way machine
(physical 4-way), it seems to hit about 2-5 minutes into the tests.
I'll back out my own changes and see what I turn up.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

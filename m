Date: Mon, 27 Jun 2005 06:04:50 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] fix WANT_PAGE_VIRTUAL in memmap_init
Message-ID: <20050627130450.GL3334@holomorphy.com>
References: <20050627105829.GX23911@localhost.localdomain> <20050627125805.GK3334@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050627125805.GK3334@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 27, 2005 at 06:58:29AM -0400, Bob Picco wrote:
>> I spotted this issue while in memmap_init last week.  I can't say the
>> change has any test coverage by me.  start_pfn was formerly used in
>> main "for" loop. The fix is replace start_pfn with pfn.

On Mon, Jun 27, 2005 at 05:58:05AM -0700, William Lee Irwin III wrote:
> Bob, this is rather serious. Could you push this to -STABLE after it
> goes to mainline (which hopefully is ASAP)?

False alarm, it's just a redundant counter (it's not even 6AM here).
Looks like someone took a dump all over this code recently. Brilliant.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

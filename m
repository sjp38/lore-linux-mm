Date: Tue, 9 Nov 2004 15:46:59 +0100
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-ID: <20041109144659.GC17639@x30.random>
References: <20041021223613.GA8756@dualathlon.random> <20041021160233.68a84971.akpm@osdl.org> <20041021232059.GE8756@dualathlon.random> <20041021164245.4abec5d2.akpm@osdl.org> <20041022003004.GA14325@dualathlon.random> <20041022012211.GD14325@dualathlon.random> <20041021190320.02dccda7.akpm@osdl.org> <20041022161744.GF14325@dualathlon.random> <20041022162433.509341e4.akpm@osdl.org> <1100009730.7478.1.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1100009730.7478.1.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Kleikamp <shaggy@austin.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2004 at 08:15:30AM -0600, Dave Kleikamp wrote:
> Andrew & Andrea,
> What is the status of this patch?  It would be nice to have it in the
> -mm4 kernel.

I think we should add an msync in front of O_DIRECT reads too (msync
won't hurt other users, and it'll provide full coherency), everything
else is ok (the msync can be added as an incremental patch). We applied
it to SUSE (without the msync) to fix your crash in pdflush.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

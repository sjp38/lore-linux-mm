Date: Fri, 22 Oct 2004 00:36:13 +0200
From: Andrea Arcangeli <andrea@novell.com>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-ID: <20041021223613.GA8756@dualathlon.random>
References: <1098393346.7157.112.camel@localhost> <20041021144531.22dd0d54.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20041021144531.22dd0d54.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Dave Kleikamp <shaggy@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Oct 21, 2004 at 02:45:31PM -0700, Andrew Morton wrote:
> Maybe we should revisit invalidate_inode_pages2().  It used to be an
> invariant that "pages which are mapped into process address space are
> always uptodate".  We broke that (good) invariant and we're now seeing
> some fallout.  There may be more.

such invariant doesn't exists since 2.4.10. There's no way to get mmaps
reload data from disk without breaking such an invariant. It's not even
for the write side, it's buffered read against O_DIRECT write that
requires breaking such invariant.

Either you fix it the above way, or you remove the BUG() in pdflush and
you simply clear the dirty bit without doing anything, both are fine,
peraphs we should do both, but the above is good to have anyways since
it's more efficient to not even show the not uptodate pages to pdflush.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

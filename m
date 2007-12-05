Date: Thu, 6 Dec 2007 00:23:23 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 17/18] mm: remove nopage
Message-ID: <20071205232322.GA5617@wotan.suse.de>
References: <20071205071547.701344000@nick.local0.net> <20071205071628.547577000@nick.local0.net> <20071205144700.729a0c98.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071205144700.729a0c98.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 05, 2007 at 02:47:00PM -0800, Andrew Morton wrote:
> On Wed, 05 Dec 2007 18:16:04 +1100
> npiggin@suse.de wrote:
> 
> > Nothing in the tree uses nopage any more. Remove support for it in the
> > core mm code and documentation (and a few stray references to it in comments).
> 
> I'll duck this for now.  It's going to take a long time to get all those
> other patches merged given my usual ~75% dropped-on-the-floor rate from
> subsystem maintainers.  Please resend when mainline is nopage-free.

Sure, no problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

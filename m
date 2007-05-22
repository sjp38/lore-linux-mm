Date: Tue, 22 May 2007 09:53:45 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 1/3] slob: rework freelist handling
Message-ID: <20070522145345.GN11115@waste.org>
References: <20070522073910.GD17051@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070522073910.GD17051@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 22, 2007 at 09:39:10AM +0200, Nick Piggin wrote:
> Here are some patches I have been working on for SLOB, which makes
> it significantly faster, and also using less dynamic memory... at
> the cost of being slightly larger static footprint and more complex
> code.
> 
> Matt was happy for the first 2 to go into -mm (and hasn't seen patch 3 yet).

These all look good, thanks Nick!

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

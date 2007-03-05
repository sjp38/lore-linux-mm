Date: Mon, 5 Mar 2007 15:05:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Remap_file_pages protection support: when to send patches?
Message-Id: <20070305150547.c30339f5.akpm@linux-foundation.org>
In-Reply-To: <200703052245.27260.blaisorblade@yahoo.it>
References: <200703052245.27260.blaisorblade@yahoo.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Blaisorblade <blaisorblade@yahoo.it>
Cc: linux-mm@kvack.org, user-mode-linux-devel@lists.sourceforge.net, Ingo Molnar <mingo@redhat.com>, Jeff Dike <jdike@addtoit.com>
List-ID: <linux-mm.kvack.org>

On Mon, 5 Mar 2007 22:45:26 +0100
Blaisorblade <blaisorblade@yahoo.it> wrote:

> Hi Andrew, I've been resurrecting lately remap_file_pages protection support 
> for UML.
> 
> I've updated it to 2.6.20 and it passes its unit test, and the 
> resulting kernel has no stability problems in my experience on my Dual Core 
> laptop (I've been using it for long time).
> 
> Since last time I sent it, I've fixed remaining problems and TODOs, and 
> cleaned up the split (I'm just improving the way patches are split). Now it 
> is a patchset with 13 patches, and the diffstat is attached.
> 
> Now I'm curious about when I should or could better send those patches - i.e. 
> when they bring less noise into the -mm tree?
> 
> This would allow me to snapshot the git and/or -mm tree, test the patches 
> against that kernel with my unit testing program, and only then send these 
> patches to get them at least included into -mm.
> 
> Any suggestion? Obviously if you want to see the code first, in the standard 
> way, I'll follow usual practice  - just tell it me (and I'll send it shortly 
> anyway, if I get no answer).

Just send them out, against next -mm please.  Be sure to cc linux-mm.

I'm going to have to ask other developers for more help reviewing and testing
things like this in the future.  Things just aren't working.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Thu, 3 Jul 2003 00:26:41 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: What to expect with the 2.6 VM
Message-ID: <20030702222641.GU23578@dualathlon.random>
References: <Pine.LNX.4.53.0307010238210.22576@skynet> <20030701022516.GL3040@dualathlon.random> <Pine.LNX.4.53.0307021641560.11264@skynet> <20030702171159.GG23578@dualathlon.random> <461030000.1057165809@flay> <20030702174700.GJ23578@dualathlon.random> <20030702214032.GH20413@holomorphy.com> <20030702220246.GS23578@dualathlon.random> <20030702221551.GH26348@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030702221551.GH26348@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, "Martin J. Bligh" <mbligh@aracnet.com>, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jul 02, 2003 at 03:15:51PM -0700, William Lee Irwin III wrote:
> What complexity? Just unmap it if you can't allocate a pte_chain and
> park it on the LRU.

the complexity in munlock to rebuild what you destroyed in mlock, that's
linear at best (and for anonymous mappings there's no objrmap, plus
objrmap isn't even linear but quadratic in its scan [hence the problem
with it], though in practice it would be normally faster than the linear
of the page scanning ;)

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Date: Mon, 16 Sep 2002 20:29:15 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: false NUMA OOM
Message-ID: <20020917032915.GL3530@holomorphy.com>
References: <20020917025035.GY2179@holomorphy.com> <3D869EAF.663B6EC3@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <3D869EAF.663B6EC3@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@zip.com.au
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
+       for (type = classzone - first_classzone; type >= 0; --type)
+               for_each_pgdat(pgdat) {
+                       zone = pgdat->node_zones + type;

On Mon, Sep 16, 2002 at 08:17:03PM -0700, Andrew Morton wrote:
> Well you'd want to start with (and prefer) the local node's zones?
> I'm also wondering whether one shouldn't just poke a remote kswapd
> and wait.

I just sort of rearranged what was already there so it wouldn't die
quite so blatantly (i.e. minimal fix). Those are also sound methods.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

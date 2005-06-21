Date: Tue, 21 Jun 2005 18:00:57 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Comparison of standard and akpm's swap allocator
Message-ID: <20050621210057.GA17909@logos.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi MM folks,

I've spent some time to write a synthetic access pattern to compare
the standard and akpm's swap allocator.

Results are interesting to me, so I've decided to share them with you. 

Please check it out at 
http://master.kernel.org/~marcelo/swap_perf/swap_perf.html

Comments are very welcome.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

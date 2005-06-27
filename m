Date: Mon, 27 Jun 2005 19:59:11 -0400 (EDT)
From: Rik Van Riel <riel@redhat.com>
Subject: Re: [PATCH] 0/2 swap token tuning
In-Reply-To: <200506271946.33083.tomlins@cam.org>
Message-ID: <Pine.LNX.4.61.0506271958400.3784@chimarrao.boston.redhat.com>
References: <Pine.LNX.4.61.0506261827500.18834@chimarrao.boston.redhat.com>
 <200506271946.33083.tomlins@cam.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Song Jiang <sjiang@lanl.gov>
List-ID: <linux-mm.kvack.org>

On Mon, 27 Jun 2005, Ed Tomlinson wrote:

> What are the suggested  values to put into /proc/sys/vm/swap_token_timeout ?
> The docs are not at all clear about this (proc/filesystems.txt).

Beats me ;)

I tried a number of values in the original implementation, and
300 seconds turned out to work fine...

-- 
The Theory of Escalating Commitment: "The cost of continuing mistakes is
borne by others, while the cost of admitting mistakes is borne by yourself."
  -- Joseph Stiglitz, Nobel Laureate in Economics
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

From: Andi Kleen <ak@suse.de>
Subject: Re: Profiling: Require buffer allocation on the correct node
Date: Thu, 10 Aug 2006 05:21:19 +0200
References: <Pine.LNX.4.64.0608091914470.5464@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608091914470.5464@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608100521.19783.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 10 August 2006 04:18, Christoph Lameter wrote:
> Profiling really suffers with off node buffers. Fail if no memory is available
> on the nodes. The profiling code can deal with these failures should
> they occur.

At least for Opterons and other small NUMAs I have my doubts this is a good strategy.
However it probably shouldn't happen very often, but if it happened it would be 
the wrong thing.

In general shouldn't there be a printk at least? Doing such things silently is a bit
nasty.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 14 Aug 2007 00:22:23 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 3/4] Embed zone_id information within the
 zonelist->zones pointer
Message-ID: <20070814002223.2d8d42c5@the-village.bc.nu>
In-Reply-To: <20070814000041.GL3406@bingen.suse.de>
References: <200708110304.55433.ak@suse.de>
	<Pine.LNX.4.64.0708131423050.28026@schroedinger.engr.sgi.com>
	<20070813225020.GE3406@bingen.suse.de>
	<Pine.LNX.4.64.0708131457190.28445@schroedinger.engr.sgi.com>
	<20070813225841.GG3406@bingen.suse.de>
	<Pine.LNX.4.64.0708131506030.28502@schroedinger.engr.sgi.com>
	<20070813230801.GH3406@bingen.suse.de>
	<Pine.LNX.4.64.0708131536340.29946@schroedinger.engr.sgi.com>
	<20070813234322.GJ3406@bingen.suse.de>
	<Pine.LNX.4.64.0708131553050.30626@schroedinger.engr.sgi.com>
	<20070814000041.GL3406@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, Lee.Schermerhorn@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The only tricky part were skbs in a few drivers, but luckily they are only
> needed for bouncing which can be done without a skb too. For RX it adds
> one copy, but we can live with that because they're only slow devices.

Usually found on slow hardware that can't cope with extra copies very
well.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

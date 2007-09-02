Subject: Re: [PATCH 5/6] Use one zonelist that is filtered by nodemask
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <Pine.LNX.4.64.0708311732580.19868@schroedinger.engr.sgi.com>
References: <20070831205139.22283.71284.sendpatchset@skynet.skynet.ie>
	 <20070831205319.22283.45590.sendpatchset@skynet.skynet.ie>
	 <Pine.LNX.4.64.0708311732580.19868@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Sun, 02 Sep 2007 12:10:04 +0100
Message-Id: <1188731404.27508.0.camel@machina.109elm.lan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-08-31 at 17:34 -0700, Christoph Lameter wrote:
> Good idea. That gets rid of the GFP_THISNODE stuff that I introduced for 
> the memoryless node patchset.
> 

Yes, I was fairly pleased with that. It makes the split look a little
strange as an early patch makes it two zonelists and a later patch makes
it one. However, there didn't seem to be a nicer way of doing it without
having multi-purpose patches.

Thanks

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

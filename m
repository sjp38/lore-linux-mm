From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH for 2.6.16] Handle holes in node mask in node fallback list initialization
Date: Fri, 17 Feb 2006 02:46:02 +0100
References: <200602170223.34031.ak@suse.de> <Pine.LNX.4.64.0602161739560.27091@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0602161739560.27091@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200602170246.03172.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: torvalds@osdl.org, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 17 February 2006 02:40, Christoph Lameter wrote:
> What happens if another node beyond higest_node comes online later?
> Or one node in between comes online?

I don't know. Whoever implements node hotplug has to handle it.
But I'm pretty sure the old code also didn't handle it, so it's not
a regression.

My primary interest is just to get all these Opterons booting again.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

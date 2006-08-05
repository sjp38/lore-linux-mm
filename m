From: Andi Kleen <ak@suse.de>
Subject: Re: linearly index zone->node_zonelists[]
Date: Sat, 5 Aug 2006 03:50:38 +0200
References: <Pine.LNX.4.64.0608041646550.5573@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0608041654380.5573@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0608041656150.5573@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0608041656150.5573@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200608050350.38241.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Saturday 05 August 2006 01:57, Christoph Lameter wrote:
> I wonder why we need this bitmask indexing into zone->node_zonelists[]?

Yes I always wondered that too.

It's probably a good idea to change this yes.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

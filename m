From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC] mbind: Restrict nodes to the currently allowed cpuset
Date: Wed, 10 Jan 2007 01:23:56 +0100
References: <Pine.LNX.4.64.0701041115220.22710@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0701041115220.22710@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200701100123.56852.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Thursday 04 January 2007 20:16, Christoph Lameter wrote:
> Currently one can specify an arbitrary node mask to mbind that includes nodes
> not allowed. If that is done with an interleave policy then we will go around
> all the nodes. Those outside of the currently allowed cpuset will be redirected
> to the border nodes. Interleave will then create imbalances at the borders
> of the cpuset.
> 
> This patch restricts the nodes to the currently allowed cpuset.

Fine by me.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

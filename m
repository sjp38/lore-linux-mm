From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 1/8] Convert higest_possible_node_id() into nr_node_ids
Date: Wed, 17 Jan 2007 09:05:16 +1100
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <20070116054748.15358.31856.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070116054748.15358.31856.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200701170905.17234.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 January 2007 16:47, Christoph Lameter wrote:

> I think having the ability to determine the maximum amount of nodes in
> a system at runtime is useful but then we should name this entry
> correspondingly and also only calculate the value once on bootup.

Are you sure this is even possible in general on systems with node
hotplug? The firmware might not pass a maximum limit.

At least CPU hotplug definitely has this issue and I don't see nodes
to be very different.

-Andi
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

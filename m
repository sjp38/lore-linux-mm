Date: Tue, 16 Jan 2007 22:19:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 5/8] Make writeout during reclaim cpuset aware
In-Reply-To: <200701171659.16290.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0701162216430.5215@schroedinger.engr.sgi.com>
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com>
 <200701171528.16854.ak@suse.de> <20070116203622.7f1b4e87.pj@sgi.com>
 <200701171659.16290.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, menage@google.com, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@sgi.com
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jan 2007, Andi Kleen wrote:

> No actually people are fairly unhappy when one node is filled with 
> file data and then they don't get local memory from it anymore.
> I get regular complaints about that for Opteron.

Switch on zone_reclaim and it will take care of it. You can even switch it 
to write mode in order to get rid of dirty pages. However, be aware of the 
significantly reduced performance since you cannot go off node without 
writeback anymore.

> That is another concern. I haven't checked recently, but it used
> to be fairly simple to put a system to its knees by oversubscribing
> a single node with a strict memory policy. Fixing that would be good.

zone_reclaim has dealt with most of those issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

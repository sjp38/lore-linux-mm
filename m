Date: Fri, 14 Sep 2007 12:35:28 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V5
Message-ID: <20070914113528.GB4168@shadowen.org>
References: <20070827222912.8b364352.akpm@linux-foundation.org> <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com> <20070827231214.99e3c33f.akpm@linux-foundation.org> <1188309928.5079.37.camel@localhost> <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com> <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com> <1188398621.5121.13.camel@localhost> <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com> <1189518975.5036.3.camel@localhost> <20070914035058.89b13fa4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070914035058.89b13fa4.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nish Aravamudan <nish.aravamudan@gmail.com>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 14, 2007 at 03:50:58AM -0700, Andrew Morton wrote:
> On Tue, 11 Sep 2007 09:56:15 -0400 Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > Should be about ready to go...
> > 
> > Lee
> > 
> > 
> > PATCH Add node 'states' sysfs class attributes v5
> > 
> > Against:  2.6.23-rc4-mm1
> > 
> > V4 -> V5:
> > + further cleanup of print_nodes_state() suggested by Chirstoph.
> > 
> > V3 -> V4:
> > + drop the annotations -- not needed with one value per file.
> > + this simplifies print_nodes_state()
> > + fix "function return type on separate line" style glitch
> > 
> > V2 -> V3:
> > + changed to per state sysfs file -- "one value per file"
> > 
> > V1 -> V2:
> > + style cleanup
> > + drop 'len' variable in print_node_states();  compute from
> >   final size.
> > 
> > Add a per node state sysfs class attribute file to
> > /sys/devices/system/node to display node state masks.
> > 
> > E.g., on a 4-cell HP ia64 NUMA platform, we have 5 nodes:
> > 4 representing the actual hardware cells and one memory-only
> > pseudo-node representing a small amount [512MB] of "hardware
> > interleaved" memory.  With this patch, in /sys/devices/system/node
> > we see:
> > 
> > #ls -1F /sys/devices/system/node
> > has_cpu
> > has_normal_memory
> > node0/
> > node1/
> > node2/
> > node3/
> > node4/
> > online
> > possible
> > #cat /sys/devices/system/node/possible
> > 0-255
> > #cat /sys/devices/system/node/online
> > 0-4
> > #cat /sys/devices/system/node/has_normal_memory
> > 0-4
> > #cat /sys/devices/system/node/has_cpu
> > 0-3
> > 
> > N.B., NOT TESTED with CONFIG_HIGHMEM=y.
> > 
> 
> So how do we get it tested with CONFIG_HIGHMEM=y?  Needs an i386
> numa machine, yes?  Perhaps Andy or Martin can remember to do this
> sometime, but they'll need a test plan ;)

Yep, let me know what needs testing and I am sure I can grab one of the
dinosaurs to get it tested.  Base, patches, what to test ...

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: by fk-out-0910.google.com with SMTP id 18so200455fkq
        for <linux-mm@kvack.org>; Wed, 29 Aug 2007 15:36:12 -0700 (PDT)
Message-ID: <29495f1d0708291536x325af1cdtcab38b2844c1fe13@mail.gmail.com>
Date: Wed, 29 Aug 2007 15:36:11 -0700
From: "Nish Aravamudan" <nish.aravamudan@gmail.com>
Subject: Re: [PATCH/RFC] Add node states sysfs class attributeS - V3
In-Reply-To: <1188423105.5121.47.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <200708242228.l7OMS5fU017948@imap1.linux-foundation.org>
	 <20070827222912.8b364352.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0708272235580.9834@schroedinger.engr.sgi.com>
	 <20070827231214.99e3c33f.akpm@linux-foundation.org>
	 <1188309928.5079.37.camel@localhost>
	 <Pine.LNX.4.64.0708281458520.17559@schroedinger.engr.sgi.com>
	 <29495f1d0708281513g406af15an8139df5fae20ad35@mail.gmail.com>
	 <1188398621.5121.13.camel@localhost>
	 <Pine.LNX.4.64.0708291039210.21184@schroedinger.engr.sgi.com>
	 <1188423105.5121.47.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, mel@skynet.ie, y-goto@jp.fujitsu.com, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On 8/29/07, Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> Here's the reworked version:
> + multiple sysfs node class attribute files
> + one value per file
> + printed as 'node list' rather than mask
> + sample output in patch description
> - still no ascii art nor animation
>
> Lee
> =====================================
>
> PATCH Add node states sysfs class attributeS v3
>
> Against:  2.6.23-rc3-mm1
>
> V2 -> V3:
> + changed to per state sysfs file -- "one value per file"
>
> V1 -> V2:
> + style cleanup
> + drop 'len' variable in print_node_states();  compute from
>   final size.
>
> Add a per node state sysfs class attribute file to
> /sys/devices/system/node to display node state masks.
>
> E.g., on a 4-cell HP ia64 NUMA platform, we have 5 nodes:
> 4 representing the actual hardware cells and one memory-only
> pseudo-node representing a small amount [512MB] of "hardware
> interleaved" memory.  With this patch, in /sys/devices/system/node
> we see:
>
> root@gwydyr(root):ls -1 /sys/devices/system/node
> cpu
> node0/
> node1/
> node2/
> node3/
> node4/
> normal_memory
> online
> possible
> root@gwydyr(root):cat /sys/devices/system/node/possible
> possible:       0-255
> root@gwydyr(root):cat /sys/devices/system/node/online
> on-line:        0-4
> root@gwydyr(root):cat /sys/devices/system/node/normal_memory
> memory:         0-4
> root@gwydyr(root):cat /sys/devices/system/node/cpu
> cpu:            0-3

Sorry if this has been mentioned before, but now that there is one
file per mask, why do we need to prefix the output with anything?

That is, I would prefer to see:

$ cat /sys/devices/system/node/cpu
0-3

I don't think outputting "cpu:" provides any extra information.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

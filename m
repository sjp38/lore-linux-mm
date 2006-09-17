Date: Sun, 17 Sep 2006 05:36:02 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060916215545.32fba5c7.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609170533140.14453@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org> <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
 <20060916215545.32fba5c7.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2006, Andrew Morton wrote:

> Well yes, there are various things one could do if one wanted to make lots
> of kernel changes.  I believe Magnus posted some patches along these lines
> a while back.

I doubt that there would be many kernel chances. This follows straight
from the ability to do node hot plug.

 > But it's not clear that we _need_ to make such changes. 
> nodes-as-containers works OK out-of-the-box.  Apart from the fact that
> get_page_from_freelist() sucks.  And speeding that up will speed up other
> workloads.

What you are doing is using nodes to partition memory into small chunks
that are then collected in a cpuset. That is not the way how nodes
or cpusets were designed to work.
 
> Would prefer to make the kernel faster, rather than more complex...

Less nodes and less zones mean smaller zonelists and therefore a faster 
kernel since we have to traverse shorter lists.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

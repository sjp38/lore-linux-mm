Date: Tue, 19 Sep 2006 12:19:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
Message-ID: <Pine.LNX.4.63.0609191218380.7779@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org> <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
 <Pine.LNX.4.63.0609191212390.7746@chino.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Sep 2006, David Rientjes wrote:
> I made a modification in my own tree that allowed numa=fake=N to break the 
> memory into N nodes that are not powers of 2 (by writing a new hash 
> function for pfn_to_nid).  I booted with numa=fake=3 which gives me one 
> node of 2G and another of 1G.  I then placed each in their own cpusets and 
> repeated the experiment.
> 

Correction: numa=fake=3 gives me three nodes, each of 1024M.  In my 
experiment I used 0-1 > mems for the usemem cpuset and 2 > mems for the 
kernel build.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

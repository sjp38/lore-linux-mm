Date: Sat, 16 Sep 2006 21:37:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <20060916161031.4b7c2470.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609162134540.13809@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060916044847.99802d21.pj@sgi.com>
 <20060916083825.ba88eee8.akpm@osdl.org> <20060916145117.9b44786d.pj@sgi.com>
 <20060916161031.4b7c2470.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2006, Andrew Morton wrote:

> I don't see how any of this could help.  If one has a memory container
> which is constructed from 50 zones, that linear search is just going to do
> a lot of linear searching when the container approaches anything like
> fullness.

One would not construct a memory container from 50 zones but build a 
single zone as a memory container of that size.

This could work by creating a new fake node and allocating a certain 
amount of  memory from the old zone for the fake node. Then one would have 
a zone that is the container and not a container that consists of 
gazillions of fake nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

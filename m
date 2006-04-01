Date: Sat, 1 Apr 2006 10:49:14 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Avoid excessive time spend on concurrent slab shrinking
In-Reply-To: <20060401183038.GY27189130@melbourne.sgi.com>
Message-ID: <Pine.LNX.4.64.0604011047340.11929@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603311441400.8465@schroedinger.engr.sgi.com>
 <20060331150120.21fad488.akpm@osdl.org> <Pine.LNX.4.64.0603311507130.8617@schroedinger.engr.sgi.com>
 <20060331153235.754deb0c.akpm@osdl.org> <Pine.LNX.4.64.0603311541260.8948@schroedinger.engr.sgi.com>
 <20060331160032.6e437226.akpm@osdl.org> <Pine.LNX.4.64.0603311619590.9173@schroedinger.engr.sgi.com>
 <20060331172518.40a5b03d.akpm@osdl.org> <20060401155942.E961681@wobbly.melbourne.sgi.com>
 <20060401183038.GY27189130@melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Nathan Scott <nathans@sgi.com>, Andrew Morton <akpm@osdl.org>, nickpiggin@yahoo.com.au, linux-mm@kvack.org, dgc@melbourne.sgi.com
List-ID: <linux-mm.kvack.org>

On Sun, 2 Apr 2006, David Chinner wrote:

> same hash chain, which tends to implicate not enough hash buckets.
> 
> > If its useful for experimenting, Christoph, you can easily tweak the
> > cluster hash size manually by dinking with xfs_iget.c::xfs_chash_init.
> 
> Just use the ihashsize mount option - the cluster hash size is proportional
> to the inode hash size which is changed by the ihashsize mount option.
> 
> Cheers,

XFS settings visible via /proc/mounts are

rw,ihashsize=32768,sunit=32,swidth=25

Not enough hash buckets? This was the default selection by xfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sat, 16 Sep 2006 08:38:25 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060916083825.ba88eee8.akpm@osdl.org>
In-Reply-To: <20060916044847.99802d21.pj@sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060916044847.99802d21.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Sat, 16 Sep 2006 04:48:47 -0700
Paul Jackson <pj@sgi.com> wrote:

> Andrew, replying to pj:
> > > We shouldn't be heavily tuning for this case, and I am not aware of any
> > > real world situations where real users would have reasonably determined
> > > otherwise, had they had full realization of what was going on.
> > 
> > gotcha ;)
> 
> In the thrill of the hunt, I overlooked one itsy bitsy detail.
> 
> This load still seems a tad artificial to me.  What real world load
> would run with 2/3's of the nodes having max'd out memory?

Pretty much all loads?  If you haven't consumed most of the "container"'s
memory then you have overprovisioned its size.

It could just be pagecache.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

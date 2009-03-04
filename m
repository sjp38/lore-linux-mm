Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 521896B00A6
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 07:55:25 -0500 (EST)
Date: Wed, 4 Mar 2009 20:54:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: drop_caches ...
Message-ID: <20090304125425.GA20435@localhost>
References: <20090304123836.GA13706@ics.muni.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090304123836.GA13706@ics.muni.cz>
Sender: owner-linux-mm@kvack.org
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Zdenek Kabelac <zkabelac@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 04, 2009 at 02:38:36PM +0200, Lukas Hejtmanek wrote:
> Hello,
> 
> > So you don't have lots of mapped pages(Mapped=51M) or tmpfs files. It's
> > strange to me that there are so many undroppable cached pages(Cached=359M),
> > and most of them lie out of the LRU queue(Active+Inactive file=53M)...
> 
> > Anyone have better clues on these 'hidden' pages?
> 
> I think he is simply using Intel driver + GEM + UXA = TONS of drm mm objects
> in tmpfs which is 'hidden' unless you have /proc/filecache to see them.

Ah I was about to ask him to try filecache before you and Zdenek kick in.

I was expecting the shm pages to be accounted in /dev/shm, however the
GEM shm pages are allocated from an in-kernel tmpfs mount...

And I noticed in filecache that you are compiling your own
/usr/local/drm/lib/libdrm_intel.so.1.0.0, now I know what are you doing ;-)

Good job, Lukas!

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 753146B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 02:07:30 -0400 (EDT)
Message-ID: <5211B608.2050401@oracle.com>
Date: Mon, 19 Aug 2013 14:07:04 +0800
From: Bob Liu <bob.liu@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH v6 0/5] zram/zsmalloc promotion
References: <1376459736-7384-1-git-send-email-minchan@kernel.org> <20130814174050.GN2296@suse.de> <20130814185820.GA2753@gmail.com> <20130815171250.GA2296@suse.de> <20130816042641.GA2893@gmail.com> <20130816083347.GD2296@suse.de> <20130819031833.GA26832@bbox> <521197B5.8030409@oracle.com> <20130819043758.GC26832@bbox> <CAA25o9RtxNjXj8bjjwQN3tJtePj-m8MfMn0WriD8A6pN-GKdCg@mail.gmail.com>
In-Reply-To: <CAA25o9RtxNjXj8bjjwQN3tJtePj-m8MfMn0WriD8A6pN-GKdCg@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Sonny Rao <sonnyrao@google.com>, Stephen Barber <smbarber@google.com>

Hi Luigi,

On 08/19/2013 01:29 PM, Luigi Semenzato wrote:
> 
> We are gearing up to evaluate zswap, but we have only ported kernels
> up to 3.8 to our hardware, so we may be missing important patches.
> 
> In our experience, and with all due respect, the linux MM is a complex
> beast, and it's difficult to predict how hard it will be for us to
> switch to zswap.  Even with the relatively simple zram, our load

I think it will be easy if zswap can also create a pseudo block device(I
already done the simple implementation [PATCH 0/4] mm: merge zram into
zswap), then it's transparent for original zram users.

> triggered bugs in other parts of the MM that took a fair amount of
> work to resolve.
> 
> I may be wrong, but the in-memory compressed block device implemented
> by zram seems like a simple device which uses a well-established API
> to the rest of the kernel.  If it is removed from the kernel, will it
> be difficult for us to carry our own patch?  Because we may have to do
> that for a while.  Of course we would prefer it if it stayed in, at
> least temporarily.
> 
> Also, could someone confirm or deny that the maximum compression ratio
> in zbud is 2?  Because we easily achieve a 2.6-2.8 compression ratio
> with our loads using zram with zsmalloc and LZO or snappy.  Losing
> that memory will cause a noticeable regression, which will encourage
> us to stick with zram.
> 
> I am hoping that our load is not so unusual that we are the only Linux
> users in this situation, and that zsmalloc (or other
> allocator-compressor with similar characteristics) will continue to
> exist, whether it is used by zram or zswap.
> 
> Thanks!
> 

-- 
Regards,
-Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

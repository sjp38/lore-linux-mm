Date: Tue, 7 Feb 2006 21:13:58 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] mm: implement swap prefetching
Message-Id: <20060207211358.8b970343.pj@sgi.com>
In-Reply-To: <200602081606.19656.kernel@kolivas.org>
References: <200602071028.30721.kernel@kolivas.org>
	<200602071502.41456.kernel@kolivas.org>
	<20060207204655.f1c69875.pj@sgi.com>
	<200602081606.19656.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@osdl.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

Con wrote:
> > If you don't do that, then consider disabling this thing entirely
> > if CONFIG_NUMA is enabled.  This swap prefetching sounds like it
> > could be a loose canon ball in a NUMA box.
> 
> That's probably a less satisfactory option since NUMA isn't that rare with the 
> light numa of commodity hardware.

You're right -- my suggestion was not a good one.

I expect that the main distros are or will be shipping their stock PC
kernel with NUMA enabled.  Most of these kernels end up on exactly the
kind of system that is the target audience for swap prefetching.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Sat, 12 May 2007 01:37:55 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] mm: swap prefetch improvements
Message-Id: <20070512013755.603cfcc3.pj@sgi.com>
In-Reply-To: <200705121821.48515.kernel@kolivas.org>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
	<200705121728.34987.kernel@kolivas.org>
	<20070512011454.50ba68a5.pj@sgi.com>
	<200705121821.48515.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: nickpiggin@yahoo.com.au, ray-lk@madrabbit.org, mingo@elte.hu, ck@vds.kolivas.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con wrote:
> Ok so change the default value for swap_prefetch to 0 when CPUSETS is enabled? 

I don't see why that special case for cpusets is needed.

I'm suggesting making no special cases for CPUSETS at all, until and
unless we find reason to.

In other words, I'm suggesting simply removing the patch lines:

-	depends on SWAP
+	depends on SWAP && !CPUSETS

I see no other mention of cpusets in your patch.  That's fine by me.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

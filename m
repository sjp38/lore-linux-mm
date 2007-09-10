Subject: Re: Group short-lived and reclaimable kernel allocations
From: Mel Gorman <mel@csn.ul.ie>
In-Reply-To: <20070910124401.5814acad.pj@sgi.com>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
	 <20070910112211.3097.86408.sendpatchset@skynet.skynet.ie>
	 <20070910124401.5814acad.pj@sgi.com>
Content-Type: text/plain
Date: Mon, 10 Sep 2007 22:15:55 +0100
Message-Id: <1189458955.9900.2.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-09-10 at 12:44 -0700, Paul Jackson wrote:
> Minor nit, Mel.
> 
> It's easier to read patches if you use the diff -p option:
> 
>        -p  --show-c-function
>               Show which C function each change is in.
> 

That's a fair comment. I normally make sure it's there but it got missed
in a few patches in this set which is awkward. Sorry about that.

-- 
Mel Gorman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

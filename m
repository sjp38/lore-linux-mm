Date: Mon, 17 Mar 2008 08:00:26 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/18] GB pages hugetlb support
Message-ID: <20080317070026.GB27015@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080316221132.7218743e.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080316221132.7218743e.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Sun, Mar 16, 2008 at 10:11:32PM -0500, Paul Jackson wrote:
> Andi,
> 
> Are all the "interesting" cpuset related changes in patch:
> 
>   [PATCH] [1/18] Convert hugeltlb.c over to pass global state around in a structure

That one and Add basic support for more than one hstate in hugetlbfs
and partly Add support to have individual hstates for each hugetlbfs mount
It all builds on each other.
Ideally look at the end result of the whole series.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

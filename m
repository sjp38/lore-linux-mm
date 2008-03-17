Date: Mon, 17 Mar 2008 08:29:31 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [0/18] GB pages hugetlb support
Message-ID: <20080317072931.GD27015@one.firstfloor.org>
References: <20080317258.659191058@firstfloor.org> <20080316221132.7218743e.pj@sgi.com> <20080317070026.GB27015@one.firstfloor.org> <20080317020018.2bf0b466.pj@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080317020018.2bf0b466.pj@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

On Mon, Mar 17, 2008 at 02:00:18AM -0500, Paul Jackson wrote:
> Andi wrote:
> > This was against 2.6.25-rc4 
> 
> Ok - I'll try that one.

I just updated to 2.6.25-rc6 base on 
ftp://firstfloor.org/pub/ak/gbpages/patches/
and gave it a quick test. So you can use that one too.

It only had a single easy reject.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: by ug-out-1314.google.com with SMTP id c2so980443ugf
        for <linux-mm@kvack.org>; Sat, 28 Jul 2007 09:29:56 -0700 (PDT)
Message-ID: <2c0942db0707280929s56cc4588obb4abf78d766af66@mail.gmail.com>
Date: Sat, 28 Jul 2007 09:29:55 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans for 2.6.23]
In-Reply-To: <20070728122139.3c7f4290@the-village.bc.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <20070727030040.0ea97ff7.akpm@linux-foundation.org>
	 <1185531918.8799.17.camel@Homer.simpson.net>
	 <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com>
	 <Pine.LNX.4.64.0707271239300.26221@asgard.lang.hm>
	 <46AAEDEB.7040003@gmail.com>
	 <Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm>
	 <46AB166A.2000300@gmail.com>
	 <20070728122139.3c7f4290@the-village.bc.nu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Rene Herman <rene.herman@gmail.com>, david@lang.hm, Daniel Hazelton <dhazelton@enter.net>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 7/28/07, Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> Actual physical disk ops are precious resource and anything that mostly
> reduces the number will be a win - not to stay swap prefetch is the right
> answer but accidentally or otherwise there are good reasons it may happen
> to help.
>
> Bigger more linear chunks of writeout/readin is much more important I
> suspect than swap prefetching.

<nod>. The larger the chunks are that we swap out, the less it
actually hurts to swap, which might make all this a moot point. Not
all I/O is created equal...

Ray

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

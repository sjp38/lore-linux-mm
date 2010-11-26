Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC6F68D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 03:06:36 -0500 (EST)
Date: Fri, 26 Nov 2010 09:06:24 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [RFC][PATCH] Cross Memory Attach v2 (resend)
Message-ID: <20101126080624.GA26764@elte.hu>
References: <20101122122847.3585b447@lilo>
 <20101122130527.c13c99d3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101122130527.c13c99d3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Brice Goglin <Brice.Goglin@inria.fr>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>


* Andrew Morton <akpm@linux-foundation.org> wrote:

> On Mon, 22 Nov 2010 12:28:47 +1030
> Christopher Yeoh <cyeoh@au1.ibm.com> wrote:
> 
> > Resending just in case the previous mail was missed rather than ignored :-)
> > I'd appreciate any comments....
> 
> Fear, uncertainty, doubt and resistance!
> 
> We have a bit of a track record of adding cool-looking syscalls and
> then regretting it a few years later.  Few people use them, and maybe
> they weren't so cool after all, and we have to maintain them for ever. 

They are often cut off at the libc level and never get into apps.

If we had tools/libc/ (mapped by the kernel automagically via the vDSO), where 
people could add new syscall usage to actual, existing, real-life libc functions, 
where the improvements could thus propagate into thousands of apps immediately, 
without requiring any rebuild of apps or even any touching of the user-space 
installation, we'd probably have _much_ more lively development in this area.

Right now it's slow and painful, and few new syscalls can break through the brick 
wall of implementation latency, app adoption disinterest due to backwards 
compatibility limitations and the resulting inevitable lack of testing and lack of 
tangible utility.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

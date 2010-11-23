Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 860226B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 00:39:09 -0500 (EST)
Message-ID: <4CEB91FA.3040209@inria.fr>
Date: Tue, 23 Nov 2010 11:05:46 +0100
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] Cross Memory Attach v2 (resend)
References: <20101122122847.3585b447@lilo> <20101122130527.c13c99d3.akpm@linux-foundation.org> <20101123195523.46e6addb@lilo>
In-Reply-To: <20101123195523.46e6addb@lilo>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

Le 23/11/2010 10:25, Christopher Yeoh a ecrit :
> On Mon, 22 Nov 2010 13:05:27 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
>   
>> We have a bit of a track record of adding cool-looking syscalls and
>> then regretting it a few years later.  Few people use them, and maybe
>> they weren't so cool after all, and we have to maintain them for
>> ever. Bugs (sometimes security-relevant ones) remain undiscovered for
>> long periods because few people use (or care about) the code.
>>
>> So I think the bar is a high one - higher than it used to be.
>> Convince us that this feature is so important that it's worth all
>> that overhead and risk?
>>     
> Well there are the benchmark results to show that there is
> real improvement for MPI implementations (well at least for those
> benchmarks ;-) There's also been a few papers written on something
> quite similar (KNEM) which goes into more detail on the potential gains.
>
> http://runtime.bordeaux.inria.fr/knem/
>
> I've also heard privately that something very similar has been used in
> at least one device driver to support intranode operations for quite a
> while
>   

Many HPC hardware vendors implemented something like this in their
custom drivers to avoid going through their network loopback for local
communication. Even if their loopback is very fast, going to the NIC and
back to same host isn't really optimal. And I think all of them kept the
traditional approach (double-copy across a shared-memory buffer) for
small messages and only switched to this single-copy model for large
messages (tens or hundreds of kB). CMA and KNEM are "standardizing" all
this work and making it portable across multiple HPC platform/networks.

Brice

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

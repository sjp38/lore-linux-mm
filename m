Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 6894C6B0007
	for <linux-mm@kvack.org>; Tue, 19 Feb 2013 13:33:17 -0500 (EST)
Message-ID: <5123C558.5080909@oracle.com>
Date: Tue, 19 Feb 2013 13:32:56 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: slab: odd BUG on kzalloc
References: <5120FDA4.2060704@oracle.com> <0000013cefe056e0-daedd018-43cd-472f-9b20-27b2a897ae2a-000000@email.amazonses.com> <5123C1F1.6050102@oracle.com> <20130219182952.GB27141@redhat.com>
In-Reply-To: <20130219182952.GB27141@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 02/19/2013 01:29 PM, Dave Jones wrote:
> On Tue, Feb 19, 2013 at 01:18:25PM -0500, Sasha Levin wrote:
> 
>  > >> [  169.930103] ---[ end trace 4d135f3def21b4bd ]---
>  > >>
>  > >> The code translates to the following in fs/pipe.c:alloc_pipe_info :
>  > >>
>  > >>         pipe = kzalloc(sizeof(struct pipe_inode_info), GFP_KERNEL);
>  > >>         if (pipe) {
>  > >>                 pipe->bufs = kzalloc(sizeof(struct pipe_buffer) * PIPE_DEF_BUFFERS, GFP_KERNEL); <=== this
>  > >>                 if (pipe->bufs) {
>  > >>                         init_waitqueue_head(&pipe->wait);
>  > 
>  > Looks like it's not specific to pipe(). I've also got this one now:
>  > 
>  > Since I've managed to reproduce it, I'll go ahead and add slub_debug and see what it tells us.
> 
> I'm curious, did you recently upgrade gcc, or other parts of the toolchain ?
> This, and one of the other 'weird' bugs you reported recently have me wondering
> if perhaps you're seeing a compiler bug.

It happened once on a kernel built on my gentoo box with is generally up to date,
but the other time the kernel was built on my mini-server running ubuntu, which
isn't updated that often.

So I don't think compiler trickery is involved.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Tue, 25 Nov 2008 15:26:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC] - support inheritance of mlocks across fork/exec
Message-Id: <20081125152651.b4c3c18f.akpm@linux-foundation.org>
In-Reply-To: <1227561707.6937.61.camel@lts-notebook>
References: <1227561707.6937.61.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, riel@redhat.com, hugh@veritas.com, kosaki.motohiro@jp.fujitsu.com, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2008 16:21:46 -0500
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> PATCH/RFC - support inheritance of mlocks across fork/exec

Linux actually used to do this by mistake.  We fixed it in
2.3.<mumble>, iirc.

> Against;  2.6.28-rc5-mmotm-081121
> 
> Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):
> 	MCL_CURRENT|MCL_INHERIT - inherit memory locks across fork()
> 	MCL_FUTURE|MCL_INHERIT - inherit "MCL_FUTURE" semantics across
> 	fork() and exec().
> 	MCL_RECURSIVE - inherit across future generations.
> 
> In support of a "lock prefix command"--e.g., mlock <cmd> <args> ...

I spent some time scratching my head over what "MCL_RECURSIVE - inherit
across future generations" means, then decided that I shouldn't need to
scratch.

This patch should get wider attention than just linux-mm denizens,
methinks.

So can you please beef up the MCL_RECURSIVE description, then resend
the patch, also cc'ing linux-kernel@vger.kernel.org,
linux-api@vger.kernel.org and linux-arch@vger.kernel.org?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

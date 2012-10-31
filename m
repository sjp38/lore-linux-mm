Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 36ABB6B0062
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 23:24:46 -0400 (EDT)
Date: Wed, 31 Oct 2012 03:24:31 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Message-ID: <20121031032431.GG2616@ZenIV.linux.org.uk>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org>
 <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home>
 <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
 <20121031022418.GE2616@ZenIV.linux.org.uk>
 <CA+55aFyU30Z2JS9XJ4KTordbAw-2EBVD7xF4K3eAhKVRCJw8YA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyU30Z2JS9XJ4KTordbAw-2EBVD7xF4K3eAhKVRCJw8YA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Tue, Oct 30, 2012 at 07:48:19PM -0700, Linus Torvalds wrote:
> On Tue, Oct 30, 2012 at 7:24 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > BTW, how serious have you been back at KS when you were talking about
> > pull requests killing a thousand of lines of code being acceptable
> > at any point in the cycle?
> 
> Well... I'm absolutely a lot more open to pull requests that kill code
> than not, but I have to admit to being a bit more worried about stuff
> like your execve/fork patches that touch very low-level code.
> 
> So I think I'll punt that for 3.8 anyway.

Oh, well... there go my blackmail plans ;-)  Seriously, though, I'm at loss
regarding several embedded architectures - arch/score, in particular,
seems to be completely orphaned.  As far as I can see, it's
	* abandoned by hw vendor (seems like they were planning to push
it game consoles, but that was just before the recession, and...)
	* abandoned by primary maintainer, who isn't employed by said
hw vendor anymore, so his old address had been bouncy for several years.
He had bothered to update it in gcc tree, but hadn't been active there
either for almost as long.  And new address in gcc tree is of form
<name>+gcc@gmail.com, so using it for kernel-related mail would seem to
be a lousy idea.
	* the second maintainer seems to be nearly MIA as well - all I can
find is Acked-by on one commit.  Cc'ed on the kernel_execve() thread, but...
no signs of life whatsoever.
	* a lot of asm glue is in "apparently never worked" state, starting
with ptrace hookup (it's clearly started its life as a mips clone, but uses
different registers for passing return value, etc.  TIF_SYSCALL_TRACE side of
that thing still assumes MIPS ABI *and* is suffering obvious bitrot)

Sigh...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

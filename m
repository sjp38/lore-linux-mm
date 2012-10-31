Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 6EF176B0071
	for <linux-mm@kvack.org>; Tue, 30 Oct 2012 22:24:38 -0400 (EDT)
Date: Wed, 31 Oct 2012 02:24:18 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v8 01/16] hashtable: introduce a small and naive hashtable
Message-ID: <20121031022418.GE2616@ZenIV.linux.org.uk>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com>
 <20121030214257.GB2681@htj.dyndns.org>
 <CA+1xoqeCKS2E4TWCUCELjDqV2pWS4v6EyV6K-=w-GRi_K6quiQ@mail.gmail.com>
 <1351646186.4004.41.camel@gandalf.local.home>
 <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzFMrOUwdHHJ5-YUtEzTHGvdRosQc+K+trjub0K-w-D3A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sasha Levin <levinsasha928@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net, mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org, eric.dumazet@gmail.com, mathieu.desnoyers@efficios.com, axboe@kernel.dk, agk@redhat.com, dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com, edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org, rds-devel@oss.oracle.com, lw@cn.fujitsu.com

On Tue, Oct 30, 2012 at 06:25:46PM -0700, Linus Torvalds wrote:

> But whatever. This series has gotten way too much bike-shedding
> anyway. I think it should just be applied, since it does remove lines
> of code overall. I'd even possibly apply it to mainline, but it seems
> to be against linux-next.

BTW, how serious have you been back at KS when you were talking about
pull requests killing a thousand of lines of code being acceptable
at any point in the cycle?  Because right now I'm sitting on a pile that
removes 2-3 times as much (~-2KLoC for stuff that got considerable
testing for most of the architectures, -3KLoC if I include fork/clone/vfork
unification series) and seeing how maintainers of a bunch of embedded
architectures seem to be MIA...  The idea of saying "screw them" and sending
a pull request becomes more and more tempting every day ;-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

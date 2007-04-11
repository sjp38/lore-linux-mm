Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3BGiP9Z027639
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 12:44:25 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3BGiNOJ151644
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 10:44:24 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3BGiN9E016722
	for <linux-mm@kvack.org>; Wed, 11 Apr 2007 10:44:23 -0600
Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <ac8af0be0704110310n1f237e2el6f34365c4aaa5969@mail.gmail.com>
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	 <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
	 <ac8af0be0704110214qdca2ee9t3b44a17341e53730@mail.gmail.com>
	 <20070411025305.b9131062.pj@sgi.com> <1176285976.6893.27.camel@twins>
	 <ac8af0be0704110310n1f237e2el6f34365c4aaa5969@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 11 Apr 2007 09:44:34 -0700
Message-Id: <1176309874.24509.52.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Jackson <pj@sgi.com>, penberg@cs.helsinki.fi, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-04-11 at 18:10 +0800, Zhao Forrest wrote:
> On 4/11/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > On Wed, 2007-04-11 at 02:53 -0700, Paul Jackson wrote:
> > > I'm confused - which end of ths stack is up?
> > >
> > > cpuset_exit doesn't call do_exit, rather it's the other
> > > way around.  But put_files_struct doesn't call do_exit,
> > > rather do_exit calls __exit_files calls put_files_struct.
> >
> > I'm guessing its x86_64 which generates crap traces.
> >
> Yes, it's x86_64. Is there a reliable way to generate stack traces under x86_64?
> Can enabling "[ ] Compile the kernel with frame pointers" help?

CONFIG_UNWIND_INFO=y
CONFIG_STACK_UNWIND=y

should help.

Thanks,
Badari



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

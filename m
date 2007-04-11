Subject: Re: Why kmem_cache_free occupy CPU for more than 10 seconds?
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <ac8af0be0704110310n1f237e2el6f34365c4aaa5969@mail.gmail.com>
References: <ac8af0be0704102317q50fe72b1m9e4825a769a63963@mail.gmail.com>
	 <84144f020704102353r7dcc3538u2e34237d3496630e@mail.gmail.com>
	 <ac8af0be0704110214qdca2ee9t3b44a17341e53730@mail.gmail.com>
	 <20070411025305.b9131062.pj@sgi.com> <1176285976.6893.27.camel@twins>
	 <ac8af0be0704110310n1f237e2el6f34365c4aaa5969@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 11 Apr 2007 12:16:55 +0200
Message-Id: <1176286615.6893.33.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zhao Forrest <forrest.zhao@gmail.com>
Cc: Paul Jackson <pj@sgi.com>, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
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

Sometimes, the best is to redo the undo of the dwarf based stack
unwinder.

But as you said, that _huge_ number of buffers might be the issue, I'm
looking through the codepaths from __blkdev_put on downwards, I suspect
we hold a single lock somewhere,...

So hold on with patching the unwinder back in (unless of course you
fancy doing so :-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

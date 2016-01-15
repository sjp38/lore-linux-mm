Return-Path: <owner-linux-mm@kvack.org>
Date: Fri, 15 Jan 2016 15:21:31 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [PATCH 07/13] aio: enabled thread based async fsync
Message-ID: <20160115202131.GH6330@kvack.org>
References: <cover.1452549431.git.bcrl@kvack.org> <80934665e0dd2360e2583522c7c7569e5a92be0e.1452549431.git.bcrl@kvack.org> <20160112011128.GC6033@dastard> <CA+55aFxtvMqHgHmHCcszV_QKQ2BY0wzenmrvc6BYN+tLFxesMA@mail.gmail.com> <20160112022548.GD6033@dastard> <CA+55aFzxSrLhOyV3VtO=Cv_J+npD8ubEP74CCF+rdt=CRipzxA@mail.gmail.com> <20160112033708.GE6033@dastard> <CA+55aFyLb8scNSYb19rK4iT_Vx5=hKxqPwRHVnETzAhEev0aHw@mail.gmail.com> <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxCM-xWVR4jC=q2wSk+-WC1Xuf+nZLoud8JwKZopnR_dQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, linux-aio@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>

On Mon, Jan 11, 2016 at 08:48:23PM -0800, Linus Torvalds wrote:
> On Mon, Jan 11, 2016 at 8:03 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> >
> > So my argument is really that I think it would be better to at least
> > look into maybe creating something less crapulent, and striving to
> > make it easy to make the old legacy interfaces be just wrappers around
> > a more capable model.
> 
> Hmm. Thinking more about this makes me worry about all the system call
> versioning and extra work done by libc.
> 
> At least glibc has traditionally decided to munge and extend on kernel
> system call interfaces, to the point where even fairly core data
> structures (like "struct stat") may not always look the same to the
> kernel as they do to user space.
> 
> So with that worry, I have to admit that maybe a limited interface -
> rather than allowing arbitrary generic async system calls - might have
> advantages. Less room for mismatches.
> 
> I'll have to think about this some more.

Any further thoughts on this after a few days worth of pondering?

		-ben

>                   Linus

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

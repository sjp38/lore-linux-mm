From: Con Kolivas <kernel@kolivas.org>
Subject: Re: [PATCH] mm: yield during swap prefetching
Date: Wed, 8 Mar 2006 13:30:56 +1100
References: <200603081013.44678.kernel@kolivas.org> <200603081322.02306.kernel@kolivas.org> <1141784834.767.134.camel@mindpipe>
In-Reply-To: <1141784834.767.134.camel@mindpipe>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200603081330.56548.kernel@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Revell <rlrevell@joe-job.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, ck@vds.kolivas.org
List-ID: <linux-mm.kvack.org>

On Wed, 8 Mar 2006 01:27 pm, Lee Revell wrote:
> On Wed, 2006-03-08 at 13:22 +1100, Con Kolivas wrote:
> > > How is the scheduler supposed to know to penalize a kernel compile
> > > taking 100% CPU but not a game using 100% CPU?
> >
> > Because being a serious desktop operating system that we are
> > (bwahahahaha) means the user should not have special privileges to run
> > something as simple as a game. Games should not need special scheduling
> > classes. We can always use 'nice' for a compile though. Real time audio
> > is a completely different world to this.
>
> Actually recent distros like the upcoming Ubuntu Dapper support the new
> RLIMIT_NICE and RLIMIT_RTPRIO so this would Just Work without any
> special privileges (well, not root anyway - you'd have to put the user
> in the right group and add one line to /etc/security/limits.conf).
>
> I think OSX also uses special scheduling classes for stuff with RT
> constraints.
>
> The only barrier I see is that games aren't specifically written to take
> advantage of RT scheduling because historically it's only been available
> to root.

Well as I said in my previous reply, games should _not_ need special 
scheduling classes. They are not written in a real time smart way and they do 
not have any realtime constraints or requirements.

Cheers,
Con

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

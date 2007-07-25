Received: by ug-out-1314.google.com with SMTP id c2so447639ugf
        for <linux-mm@kvack.org>; Wed, 25 Jul 2007 09:09:02 -0700 (PDT)
Message-ID: <2c0942db0707250909r435fef75sa5cbf8b1c766000b@mail.gmail.com>
Date: Wed, 25 Jul 2007 09:09:01 -0700
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: -mm merge plans for 2.6.23
In-Reply-To: <46A6E1A1.4010508@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070710013152.ef2cd200.akpm@linux-foundation.org>
	 <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	 <46A57068.3070701@yahoo.com.au>
	 <2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>
	 <46A58B49.3050508@yahoo.com.au>
	 <2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>
	 <46A6CC56.6040307@yahoo.com.au> <46A6D7D2.4050708@gmail.com>
	 <1185341449.7105.53.camel@perkele> <46A6E1A1.4010508@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Eric St-Laurent <ericstl34@sympatico.ca>, Rene Herman <rene.herman@gmail.com>, Jesper Juhl <jesper.juhl@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, ck list <ck@vds.kolivas.org>, Ingo Molnar <mingo@elte.hu>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hey Eric,

On 7/24/07, Nick Piggin <nickpiggin@yahoo.com.au> wrote:
> Eric St-Laurent wrote:
> > On Wed, 2007-25-07 at 06:55 +0200, Rene Herman wrote:
> >
> >
> >>It certainly doesn't run for me ever. Always kind of a "that's not the
> >>point" comment but I just keep wondering whenever I see anyone complain
> >>about updatedb why the _hell_ they are running it in the first place. If
> >>anyone who never uses "locate" for anything simply disable updatedb, the
> >>problem will for a large part be solved.
> >>
> >>This not just meant as a cheap comment; while I can think of a few similar
> >>loads even on the desktop (scanning a browser cache, a media player indexing
> >>a large amount of media files, ...) I've never heard of problems _other_
> >>than updatedb. So just junk that crap and be happy.
> >
> >
> >>From my POV there's two different problems discussed recently:
> >
> > - updatedb type of workloads that add tons of inodes and dentries in the
> > slab caches which of course use the pagecache.
> >
> > - streaming large files (read or copying) that fill the pagecache with
> > useless used-once data

No, there's a third case which I find the most annoying. I have
multiple working sets, the sum of which won't fit into RAM. When I
finish one, the kernel had time to preemptively swap back in the
other, and yet it didn't. So, I sit around, twiddling my thumbs,
waiting for my music player to come back to life, or thunderbird,
or...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

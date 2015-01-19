Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id B68756B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:20:13 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so4704151pdb.6
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:20:13 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id kv14si1541587pab.28.2015.01.19.09.20.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 09:20:12 -0800 (PST)
Date: Mon, 19 Jan 2015 09:20:15 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150119172015.GA13428@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP>
 <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
 <20150119170429.GA13160@jeremy-HP>
 <CACyXjPzTE0FHt5B5HL1DOLrTWqFqy_rgbFRXd1k88m8zPunbPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACyXjPzTE0FHt5B5HL1DOLrTWqFqy_rgbFRXd1k88m8zPunbPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Sharpe <realrichardsharpe@gmail.com>
Cc: Jeremy Allison <jra@samba.org>, Milosz Tanski <milosz@adfin.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 09:18:14AM -0800, Richard Sharpe wrote:
> On Mon, Jan 19, 2015 at 9:04 AM, Jeremy Allison <jra@samba.org> wrote:
> > On Mon, Jan 19, 2015 at 2:34 AM, James Bottomley
> > <James.Bottomley@hansenpartnership.com> wrote:
> >>
> >> That's one of these pointless licensing complexities that annoy
> >> distributions so much ... they're both open source, so there's no real
> >> problem except the licence incompatibility. The usual way out of it is
> >> just to dual licence the incompatible component.
> >
> > Just one point here - we're not able to dual license
> > Samba to go back to GPLv2 anything. There are too many
> > contributors to this who have contributed under v3-or-later
> > licensing in order for this to be possible for us.
> >
> > I'm hoping adding the 'or-later' clause to fio might
> > be easier.
> 
> As someone who has worked for companies that distribute Samba for
> quite a while I cannot see us distributing fio. Rather, we would use
> it as a performance testing tool.
> 
> That being the case, the license differences are not a problem.
> 
> Am I missing something here?

No, it's only a problem for distributors, so it's
much less of a problem than it might be.

But it's still a problem I'd rather not have to
think about :-).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

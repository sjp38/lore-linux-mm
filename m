Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 56DA96B006E
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 21:22:45 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so32727225pad.4
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 18:22:45 -0800 (PST)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id a3si7959937pdi.187.2015.01.28.18.22.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 Jan 2015 18:22:44 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so32753531pac.2
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 18:22:44 -0800 (PST)
Date: Thu, 29 Jan 2015 11:22:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v1 2/2] zram: remove init_lock in zram_make_request
Message-ID: <20150129022241.GA2555@swordfish>
References: <1422432945-6764-1-git-send-email-minchan@kernel.org>
 <1422432945-6764-2-git-send-email-minchan@kernel.org>
 <20150128145651.GB965@swordfish>
 <20150128233343.GC4706@blaptop>
 <CAHqPoqKZFDSjO1pL+ixYe_m_L0nGNcu04qSNp-jd1fUixKtHnw@mail.gmail.com>
 <20150129020139.GB9672@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150129020139.GB9672@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Nitin Gupta <ngupta@vflare.org>, Jerome Marchand <jmarchan@redhat.com>, Ganesh Mahendran <opensource.ganesh@gmail.com>, sergey.senozhatsky.work@gmail.com

On (01/29/15 11:01), Minchan Kim wrote:
> On Thu, Jan 29, 2015 at 10:57:38AM +0900, Sergey Senozhatsky wrote:
> > On Thu, Jan 29, 2015 at 8:33 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > On Wed, Jan 28, 2015 at 11:56:51PM +0900, Sergey Senozhatsky wrote:
> > > > I don't like re-introduced ->init_done.
> > > > another idea... how about using `zram->disksize == 0' instead of
> > > > `->init_done' (previously `->meta != NULL')? should do the trick.
> > >
> > > It could be.
> > >
> > >
> > care to change it?
> 
> Will try!
> 
> If it was your concern, I'm happy to remove the check.(ie, actually,
> I realized that after I push the button to send). Thanks!
> 

Thanks a lot, Minchan.

and, guys, sorry for previous html email (I'm sure I toggled the "plain
text" mode in gmail web-interface, but somehow it has different meaning
in gmail world).


I'm still concerned about performance numbers that I see on my x86_64.
it's not always, but mostly slower. I'll give it another try (disable
lockdep, etc.), but if we lose 10% on average then, sorry, I'm not so
positive about srcu change and will tend to vote for your initial commit
that simply moved meta free() out of init_lock and left locking as is
(lockdep warning would have been helpful there, because otherwise it
just looked like we change code w/o any reason).

what do you thunk?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

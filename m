Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id DD5516B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:26:58 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so8480591pdb.11
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:26:58 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTP id t3si17163143pdc.177.2015.01.19.09.26.56
        for <linux-mm@kvack.org>;
        Mon, 19 Jan 2015 09:26:57 -0800 (PST)
Message-ID: <1421688414.2080.38.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for
 userspace apps
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 19 Jan 2015 09:26:54 -0800
In-Reply-To: <20150119164857.GC12308@jeremy-HP>
References: 
	<CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	 <20150115223157.GB25884@quack.suse.cz>
	 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	 <20150116165506.GA10856@samba2>
	 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	 <20150119071218.GA9747@jeremy-HP>
	 <1421652849.2080.20.camel@HansenPartnership.com>
	 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	 <54BD234F.3060203@kernel.dk>
	 <1421682581.2080.22.camel@HansenPartnership.com>
	 <20150119164857.GC12308@jeremy-HP>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Allison <jra@samba.org>
Cc: Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Milosz Tanski <milosz@adfin.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, 2015-01-19 at 08:48 -0800, Jeremy Allison wrote:
> On Mon, Jan 19, 2015 at 07:49:41AM -0800, James Bottomley wrote:
> > 
> > For fio, it likely doesn't matter.  Most people download the repository
> > and compile it themselves when building the tool. In that case, there's
> > no licence violation anyway (all GPL issues, including technical licence
> > incompatibility, manifest on distribution not on use).  It is a problem
> > for the distributors, but they're well used to these type of self
> > inflicted wounds.
> 
> That's true, but it is setting a bear-trap for distributors.

It's hardly a bear trap ... this type of annoyance is what they're used
to.  Some even just ignore it on the grounds of no harm no foul.  The
first thing they'll ask when they notice is for the protagonists to dual
licence.

> Might be better to keep the code repositories separate so at
> lease people have a *chance* of noticing there's a problem
> here.

Actually, it might be better to *resolve* the problem before people
notice ... if the combination is considered useful, of course.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

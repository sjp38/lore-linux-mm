Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7EB516B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:04:27 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so39905117pab.0
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:04:27 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id gt6si1127281pac.204.2015.01.19.09.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 09:04:26 -0800 (PST)
Date: Mon, 19 Jan 2015 09:04:29 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150119170429.GA13160@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP>
 <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 2:34 AM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
>
> That's one of these pointless licensing complexities that annoy
> distributions so much ... they're both open source, so there's no real
> problem except the licence incompatibility. The usual way out of it is
> just to dual licence the incompatible component.

Just one point here - we're not able to dual license
Samba to go back to GPLv2 anything. There are too many
contributors to this who have contributed under v3-or-later
licensing in order for this to be possible for us.

I'm hoping adding the 'or-later' clause to fio might
be easier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

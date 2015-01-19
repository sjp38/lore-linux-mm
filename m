Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E926F6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 11:48:56 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so39814359pab.6
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 08:48:56 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id qf1si1094585pab.192.2015.01.19.08.48.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 08:48:54 -0800 (PST)
Date: Mon, 19 Jan 2015 08:48:57 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150119164857.GC12308@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP>
 <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
 <54BD234F.3060203@kernel.dk>
 <1421682581.2080.22.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421682581.2080.22.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jens Axboe <axboe@kernel.dk>, Milosz Tanski <milosz@adfin.com>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, Jeremy Allison <jra@samba.org>

On Mon, Jan 19, 2015 at 07:49:41AM -0800, James Bottomley wrote:
> 
> For fio, it likely doesn't matter.  Most people download the repository
> and compile it themselves when building the tool. In that case, there's
> no licence violation anyway (all GPL issues, including technical licence
> incompatibility, manifest on distribution not on use).  It is a problem
> for the distributors, but they're well used to these type of self
> inflicted wounds.

That's true, but it is setting a bear-trap for distributors.

Might be better to keep the code repositories separate so at
lease people have a *chance* of noticing there's a problem
here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

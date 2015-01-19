Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 76E066B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 11:50:28 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id eu11so5444086pac.13
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 08:50:28 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id bd4si1395566pad.46.2015.01.19.08.50.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 08:50:27 -0800 (PST)
Date: Mon, 19 Jan 2015 08:50:30 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150119165030.GD12308@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP>
 <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
 <54BD234F.3060203@kernel.dk>
 <E1YDEuL-000mD3-8B@intern.SerNet.DE>
 <CANP1eJEgbsX2wcREwfcsPmo8k1ZMf-ZXimH19ZsvGCRO+MT-6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANP1eJEgbsX2wcREwfcsPmo8k1ZMf-ZXimH19ZsvGCRO+MT-6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: Volker Lendecke <Volker.Lendecke@sernet.de>, Jens Axboe <axboe@kernel.dk>, James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 11:20:50AM -0500, Milosz Tanski wrote:
> 
> Volker, the sync code path works; in fact I pushed some minor
> corrections to my branch this morning. And for now using FIO I can
> generate multiple clients (threads / processes).
> 
> I started working on the async features (SMB2 async read/write) for
> client library the samba repo. There's a patch there for the first
> step of it it there; see the other email I sent to you and Jeremy. I
> was going to make sure it licensed under whatever it needs to get into
> the samba repo... and since this is done on my own time I personally
> don't care what license it's under provided it's not a PITA.

Anything going into Samba would need to be permissively licensed
(MIT/BSD) or GPLv3+ or LGPLv3+. We'd prefer the latter, but we're
happy with either.

The one thing it *can't* be though, is GPLv2-only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3C0786B0032
	for <linux-mm@kvack.org>; Fri, 23 Jan 2015 18:15:38 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id dc16so178589qab.1
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 15:15:38 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com. [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id q1si4027703qaj.14.2015.01.23.15.15.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Jan 2015 15:15:37 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id v10so173103qac.2
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 15:15:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CANP1eJEgbsX2wcREwfcsPmo8k1ZMf-ZXimH19ZsvGCRO+MT-6Q@mail.gmail.com>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz> <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2> <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP> <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
 <54BD234F.3060203@kernel.dk> <E1YDEuL-000mD3-8B@intern.SerNet.DE> <CANP1eJEgbsX2wcREwfcsPmo8k1ZMf-ZXimH19ZsvGCRO+MT-6Q@mail.gmail.com>
From: Steve French <smfrench@gmail.com>
Date: Fri, 23 Jan 2015 17:15:16 -0600
Message-ID: <CAH2r5mv29sv1jz=Oh+BJY8hokZtLFMReVUZ=RLX-36yAwXOXoA@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: Volker Lendecke <Volker.Lendecke@sernet.de>, Jens Axboe <axboe@kernel.dk>, James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On Mon, Jan 19, 2015 at 10:20 AM, Milosz Tanski <milosz@adfin.com> wrote:
> On Mon, Jan 19, 2015 at 11:10 AM, Volker Lendecke
> <Volker.Lendecke@sernet.de> wrote:
>> On Mon, Jan 19, 2015 at 08:31:27AM -0700, Jens Axboe wrote:
>>> I didn't look at your code yet, but I'm assuming it's a self
>>> contained IO engine. So we should be able to make that work, by only
>>> linking the engine itself against libsmbclient. But sheesh, what a
>>> pain in the butt, why can't we just all be friends.
>>
>> The published libsmbclient API misses the async features
>> that are needed here. Milosz needs to go lower-level.
>>
>> Volker
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

Why not do the async read/write via the kernel client if the license
is an issue?  It already has async SMB2/SMB3 operations
(with a synchronous send/receive-like wrapper).



-- 
Thanks,

Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id D3B516B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 18:00:47 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id z10so4679509pdj.13
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 15:00:47 -0800 (PST)
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com. [209.85.192.180])
        by mx.google.com with ESMTPS id 12si6940766pde.142.2015.01.24.15.00.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 24 Jan 2015 15:00:46 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so4704395pdb.11
        for <linux-mm@kvack.org>; Sat, 24 Jan 2015 15:00:45 -0800 (PST)
Message-ID: <54C4241C.9070406@kernel.dk>
Date: Sat, 24 Jan 2015 16:00:44 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
References: <20150116165506.GA10856@samba2> <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com> <20150119071218.GA9747@jeremy-HP> <1421652849.2080.20.camel@HansenPartnership.com> <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com> <54BD234F.3060203@kernel.dk> <E1YDEuL-000mD3-8B@intern.SerNet.DE> <CANP1eJEgbsX2wcREwfcsPmo8k1ZMf-ZXimH19ZsvGCRO+MT-6Q@mail.gmail.com> <CAH2r5mv29sv1jz=Oh+BJY8hokZtLFMReVUZ=RLX-36yAwXOXoA@mail.gmail.com> <54C300A1.7040202@kernel.dk> <20150124055352.GE6636@jeremy-HP>
In-Reply-To: <20150124055352.GE6636@jeremy-HP>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Allison <jra@samba.org>
Cc: Steve French <smfrench@gmail.com>, Milosz Tanski <milosz@adfin.com>, Volker Lendecke <Volker.Lendecke@sernet.de>, James Bottomley <James.Bottomley@hansenpartnership.com>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>

On 01/23/2015 10:53 PM, Jeremy Allison wrote:
> On Fri, Jan 23, 2015 at 07:17:05PM -0700, Jens Axboe wrote:
>> On 01/23/2015 04:15 PM, Steve French wrote:
>>> On Mon, Jan 19, 2015 at 10:20 AM, Milosz Tanski <milosz@adfin.com> wrote:
>>>> On Mon, Jan 19, 2015 at 11:10 AM, Volker Lendecke
>>>> <Volker.Lendecke@sernet.de> wrote:
>>>>> On Mon, Jan 19, 2015 at 08:31:27AM -0700, Jens Axboe wrote:
>>>>>> I didn't look at your code yet, but I'm assuming it's a self
>>>>>> contained IO engine. So we should be able to make that work, by only
>>>>>> linking the engine itself against libsmbclient. But sheesh, what a
>>>>>> pain in the butt, why can't we just all be friends.
>>>>>
>>>>> The published libsmbclient API misses the async features
>>>>> that are needed here. Milosz needs to go lower-level.
>>>>>
>>>>> Volker
>>>>
>>>> Volker, the sync code path works; in fact I pushed some minor
>>>> corrections to my branch this morning. And for now using FIO I can
>>>> generate multiple clients (threads / processes).
>>>>
>>>> I started working on the async features (SMB2 async read/write) for
>>>> client library the samba repo. There's a patch there for the first
>>>> step of it it there; see the other email I sent to you and Jeremy. I
>>>> was going to make sure it licensed under whatever it needs to get into
>>>> the samba repo... and since this is done on my own time I personally
>>>> don't care what license it's under provided it's not a PITA.
>>>
>>> Why not do the async read/write via the kernel client if the license
>>> is an issue?  It already has async SMB2/SMB3 operations
>>> (with a synchronous send/receive-like wrapper).
>>
>> The license issue has been solved. Fio is cross platform, so would
>> be preferable to have this work through libsmbclient, if at all
>> possible.
>
> How did the license issue get solved ? Did I miss some email
> on that ?

Only the cifs engine is linked with libsmbclient, so that particular 
engine can be licensed as v2 or later (or v3, u to Milosz).

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

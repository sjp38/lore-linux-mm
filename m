Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 563C26B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:18:53 -0500 (EST)
Received: by mail-lb0-f180.google.com with SMTP id b6so2932461lbj.11
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:18:50 -0800 (PST)
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com. [209.85.215.51])
        by mx.google.com with ESMTPS id or2si11769393lbb.91.2015.01.19.06.18.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 06:18:50 -0800 (PST)
Received: by mail-la0-f51.google.com with SMTP id ge10so8046728lab.10
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 06:18:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1421652849.2080.20.camel@HansenPartnership.com>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	<20150119071218.GA9747@jeremy-HP>
	<1421652849.2080.20.camel@HansenPartnership.com>
Date: Mon, 19 Jan 2015 09:18:49 -0500
Message-ID: <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Jeremy Allison <jra@samba.org>, Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 2:34 AM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> On Sun, 2015-01-18 at 23:12 -0800, Jeremy Allison wrote:
>> On Sun, Jan 18, 2015 at 10:49:36PM -0500, Milosz Tanski wrote:
>> >
>> > I have the first version of the FIO cifs support via samba in my fork
>> > of FIO here: https://github.com/mtanski/fio/tree/samba
>> >
>> > Right now it only supports sync mode of FIO (eg. can't submit multiple
>> > outstanding requests) but I'm looking into how to make it work with
>> > smb2 read/write calls with the async flag.
>> >
>> > Additionally, I'm sure I'm doing some things not quite right in terms
>> > of smbcli usage as it was a decent amount of trial and error to get it
>> > to connect (esp. the setup before smbcli_full_connection). Finally, it
>> > looks like the more complex api I'm using (as opposed to smbclient,
>> > because I want the async calls) doesn't quite fully export all calls I
>> > need via headers / public dyn libs so it's a bit of a hack to get it
>> > to build: https://github.com/mtanski/fio/commit/7fd35359259b409ed023b924cb2758e9efb9950c#diff-1
>> >
>> > But it works for my randread tests with zipf and the great part is
>> > that it should provide a flexible way to test samba with many fake
>> > clients and access patterns. So... progress.
>>
>> One problem here. Looks like fio is under GPLv2-only,
>> is that correct ?
>
> Seems so from the LICENSE file.
>
>> If so there's no way to combine the two codebases,
>> as Samba is under GPLv3-or-later with parts under LGPLv3-or-later.
>>
>> fio needs to be GPLv2-or-later in order to be
>> able to use with libsmbclient.
>
> That's one of these pointless licensing complexities that annoy
> distributions so much ... they're both open source, so there's no real
> problem except the licence incompatibility. The usual way out of it is
> just to dual licence the incompatible component.
>
> James
>
>

Sadly, in this case there's nothing I can do about the license; both
projects have a right to determine their own licensing. Hopefully, the
parties can come to some kind of agreement since it would be
beneficial to use fio to test samba.

This works well enough for me to test test preadv2 using samba and get
numbers. So I'll use this to do some preadv2 testing using samba for
different workloads.

-- 
Milosz Tanski
CTO
16 East 34th Street, 15th floor
New York, NY 10016

p: 646-253-9055
e: milosz@adfin.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

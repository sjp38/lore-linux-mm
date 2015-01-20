Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF946B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 18:53:59 -0500 (EST)
Received: by mail-la0-f52.google.com with SMTP id hs14so37295398lab.11
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:53:58 -0800 (PST)
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com. [209.85.215.41])
        by mx.google.com with ESMTPS id t10si17915935lat.56.2015.01.20.15.53.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 15:53:58 -0800 (PST)
Received: by mail-la0-f41.google.com with SMTP id gm9so11267882lab.0
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:53:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <54BEE51F.7080400@kernel.dk>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
	<20150115223157.GB25884@quack.suse.cz>
	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
	<20150116165506.GA10856@samba2>
	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
	<20150119071218.GA9747@jeremy-HP>
	<1421652849.2080.20.camel@HansenPartnership.com>
	<CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
	<54BD234F.3060203@kernel.dk>
	<54BEAD82.3070501@kernel.dk>
	<CANP1eJG36DYG8xezydcuWAw6d-Khz9ULr9WMuJ6kfpPzJEoOXw@mail.gmail.com>
	<CANP1eJHqhYZ9_yf16LKaUMvHEJN7eERpKSBYVrtQhr8ZkGVVsQ@mail.gmail.com>
	<54BEE436.4020205@kernel.dk>
	<54BEE51F.7080400@kernel.dk>
Date: Tue, 20 Jan 2015 18:53:57 -0500
Message-ID: <CANP1eJH=-ounu9RCtWntnS4nLFVZYaUJg26AUn1=MZFCpeVFTQ@mail.gmail.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace apps
From: Milosz Tanski <milosz@adfin.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Tue, Jan 20, 2015 at 6:30 PM, Jens Axboe <axboe@kernel.dk> wrote:
> On 01/20/2015 04:26 PM, Jens Axboe wrote:
>> On 01/20/2015 04:22 PM, Milosz Tanski wrote:
>>> Side note Jens.
>>>
>>> Can you add a configure flag to disable use of SHM (like for ESX)? It
>>> took me a while to figure out the proper define to manually stick in
>>> the configure.
>>>
>>> The motivation for this is using rr (mozila's replay debugger) to
>>> debug fio. rr doesn't support SHM. http://rr-project.org/ gdb's
>>> reversible debugging is too painfully slow.
>>
>> Yeah definitely, that's mean that thread=1 would be a requirement,
>> obviously. But I'd be fine with adding that flag.
>
> http://git.kernel.dk/?p=fio.git;a=commit;h=ba40757ed67c00b37dda3639e97c3ba0259840a4

Great, thanks for fixing it so quickly. Hopefully it'll be useful to
others as well.

- M

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

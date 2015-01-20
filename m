Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7646B006E
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 18:30:26 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so18160394pab.11
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:30:26 -0800 (PST)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com. [209.85.220.43])
        by mx.google.com with ESMTPS id rk11si6530890pab.99.2015.01.20.15.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 15:30:24 -0800 (PST)
Received: by mail-pa0-f43.google.com with SMTP id eu11so11480290pac.2
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 15:30:24 -0800 (PST)
Message-ID: <54BEE51F.7080400@kernel.dk>
Date: Tue, 20 Jan 2015 16:30:39 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>	<20150115223157.GB25884@quack.suse.cz>	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>	<20150116165506.GA10856@samba2>	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>	<20150119071218.GA9747@jeremy-HP>	<1421652849.2080.20.camel@HansenPartnership.com>	<CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>	<54BD234F.3060203@kernel.dk>	<54BEAD82.3070501@kernel.dk>	<CANP1eJG36DYG8xezydcuWAw6d-Khz9ULr9WMuJ6kfpPzJEoOXw@mail.gmail.com> <CANP1eJHqhYZ9_yf16LKaUMvHEJN7eERpKSBYVrtQhr8ZkGVVsQ@mail.gmail.com> <54BEE436.4020205@kernel.dk>
In-Reply-To: <54BEE436.4020205@kernel.dk>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On 01/20/2015 04:26 PM, Jens Axboe wrote:
> On 01/20/2015 04:22 PM, Milosz Tanski wrote:
>> Side note Jens.
>>
>> Can you add a configure flag to disable use of SHM (like for ESX)? It
>> took me a while to figure out the proper define to manually stick in
>> the configure.
>>
>> The motivation for this is using rr (mozila's replay debugger) to
>> debug fio. rr doesn't support SHM. http://rr-project.org/ gdb's
>> reversible debugging is too painfully slow.
> 
> Yeah definitely, that's mean that thread=1 would be a requirement,
> obviously. But I'd be fine with adding that flag.

http://git.kernel.dk/?p=fio.git;a=commit;h=ba40757ed67c00b37dda3639e97c3ba0259840a4


-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

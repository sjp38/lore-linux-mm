Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE7A6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 15:00:45 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so40701851pab.6
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:00:45 -0800 (PST)
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com. [209.85.192.174])
        by mx.google.com with ESMTPS id i4si546093pdj.216.2015.01.19.12.00.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 12:00:43 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id ft15so9143412pdb.5
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:00:42 -0800 (PST)
Message-ID: <54BD6267.1090106@kernel.dk>
Date: Mon, 19 Jan 2015 13:00:39 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com> <20150115223157.GB25884@quack.suse.cz> <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com> <20150116165506.GA10856@samba2> <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com> <20150119071218.GA9747@jeremy-HP> <1421652849.2080.20.camel@HansenPartnership.com> <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com> <54BD234F.3060203@kernel.dk> <1421682581.2080.22.camel@HansenPartnership.com> <20150119164857.GC12308@jeremy-HP>
In-Reply-To: <20150119164857.GC12308@jeremy-HP>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeremy Allison <jra@samba.org>, James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Milosz Tanski <milosz@adfin.com>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On 01/19/2015 09:48 AM, Jeremy Allison wrote:
> On Mon, Jan 19, 2015 at 07:49:41AM -0800, James Bottomley wrote:
>>
>> For fio, it likely doesn't matter.  Most people download the repository
>> and compile it themselves when building the tool. In that case, there's
>> no licence violation anyway (all GPL issues, including technical licence
>> incompatibility, manifest on distribution not on use).  It is a problem
>> for the distributors, but they're well used to these type of self
>> inflicted wounds.
>
> That's true, but it is setting a bear-trap for distributors.

But not unique. Most distros are behind on fio anyway, so most people do 
end up compiling on their own.

> Might be better to keep the code repositories separate so at
> lease people have a *chance* of noticing there's a problem
> here.

But that's a pain for users, I'd much rather include it and let the 
distro sort it. They can just add --disable-smb or something to their 
configure scripts.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 17AFF6B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 14:33:28 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so47639783pab.7
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 11:33:27 -0800 (PST)
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com. [209.85.192.180])
        by mx.google.com with ESMTPS id oh2si1131537pdb.122.2015.01.20.11.33.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 Jan 2015 11:33:25 -0800 (PST)
Received: by mail-pd0-f180.google.com with SMTP id ft15so15638561pdb.11
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 11:33:24 -0800 (PST)
Message-ID: <54BEAD82.3070501@kernel.dk>
Date: Tue, 20 Jan 2015 12:33:22 -0700
From: Jens Axboe <axboe@kernel.dk>
MIME-Version: 1.0
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>	<20150115223157.GB25884@quack.suse.cz>	<CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>	<20150116165506.GA10856@samba2>	<CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>	<20150119071218.GA9747@jeremy-HP>	<1421652849.2080.20.camel@HansenPartnership.com> <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com> <54BD234F.3060203@kernel.dk>
In-Reply-To: <54BD234F.3060203@kernel.dk>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>, James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Jeremy Allison <jra@samba.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On 01/19/2015 08:31 AM, Jens Axboe wrote:
> I didn't look at your code yet, but I'm assuming it's a self contained
> IO engine. So we should be able to make that work, by only linking the
> engine itself against libsmbclient. But sheesh, what a pain in the butt,
> why can't we just all be friends.

I pulled it in for testing, and came up with this patch [1]. If you 
don't do anything, it'll build cifs into fio as before. If you add 
--cifs-external to the configure arguments, it'll build cifs.so as an 
externally loadable module. You'd then use:

ioengine=/path/to/cifs.so

to use that module. I did not add an install target, I'll leave that to 
distros...

Let me know how that works for you. And let me know how far along you 
are with the cifs engine, I'd like to pull it in.

http://git.kernel.dk/?p=fio.git;a=shortlog;h=refs/heads/cifs

[1] 
http://git.kernel.dk/?p=fio.git;a=commit;h=c2c05e33b753ae686e24b43d1034d0c474203729

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

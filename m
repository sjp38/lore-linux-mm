Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 28B436B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 02:12:18 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id g10so1862526pdj.12
        for <linux-mm@kvack.org>; Sun, 18 Jan 2015 23:12:17 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id nm9si14655755pbc.221.2015.01.18.23.12.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 18 Jan 2015 23:12:16 -0800 (PST)
Date: Sun, 18 Jan 2015 23:12:18 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150119071218.GA9747@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milosz Tanski <milosz@adfin.com>
Cc: Jeremy Allison <jra@samba.org>, Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, Christoph Hellwig <hch@infradead.org>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jens Axboe <axboe@kernel.dk>

On Sun, Jan 18, 2015 at 10:49:36PM -0500, Milosz Tanski wrote:
> 
> I have the first version of the FIO cifs support via samba in my fork
> of FIO here: https://github.com/mtanski/fio/tree/samba
> 
> Right now it only supports sync mode of FIO (eg. can't submit multiple
> outstanding requests) but I'm looking into how to make it work with
> smb2 read/write calls with the async flag.
> 
> Additionally, I'm sure I'm doing some things not quite right in terms
> of smbcli usage as it was a decent amount of trial and error to get it
> to connect (esp. the setup before smbcli_full_connection). Finally, it
> looks like the more complex api I'm using (as opposed to smbclient,
> because I want the async calls) doesn't quite fully export all calls I
> need via headers / public dyn libs so it's a bit of a hack to get it
> to build: https://github.com/mtanski/fio/commit/7fd35359259b409ed023b924cb2758e9efb9950c#diff-1
> 
> But it works for my randread tests with zipf and the great part is
> that it should provide a flexible way to test samba with many fake
> clients and access patterns. So... progress.

One problem here. Looks like fio is under GPLv2-only,
is that correct ?

If so there's no way to combine the two codebases,
as Samba is under GPLv3-or-later with parts under LGPLv3-or-later.

fio needs to be GPLv2-or-later in order to be
able to use with libsmbclient.

Cheers,

	Jeremy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DF2846B0270
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 11:04:10 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u63so14331986wmu.0
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 08:04:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j3si17017710wra.42.2017.01.30.08.04.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 08:04:09 -0800 (PST)
Date: Mon, 30 Jan 2017 17:04:06 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] I/O error handling and fsync()
Message-ID: <20170130160406.GB23022@quack2.suse.cz>
References: <20170123100941.GA5745@noname.redhat.com>
 <1485210957.2786.19.camel@poochiereds.net>
 <1485212994.3722.1.camel@primarydata.com>
 <878tq1ia6l.fsf@notabene.neil.brown.name>
 <1485228841.8987.1.camel@primarydata.com>
 <20170125183542.557drncuktc5wgzy@thunk.org>
 <87ziieu06k.fsf@notabene.neil.brown.name>
 <20170126092542.GA17099@quack2.suse.cz>
 <87r33ptqg1.fsf@notabene.neil.brown.name>
 <20170127032318.rkdiwu6nog3nifdo@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170127032318.rkdiwu6nog3nifdo@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: NeilBrown <neilb@suse.com>, "kwolf@redhat.com" <kwolf@redhat.com>, "riel@redhat.com" <riel@redhat.com>, Jan Kara <jack@suse.cz>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Trond Myklebust <trondmy@primarydata.com>, "jlayton@poochiereds.net" <jlayton@poochiereds.net>, "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "rwheeler@redhat.com" <rwheeler@redhat.com>

On Thu 26-01-17 22:23:18, Ted Tso wrote:
> > And aio_write() isn't non-blocking for O_DIRECT already because .... oh,
> > it doesn't even try.  Is there something intrinsically hard about async
> > O_DIRECT writes, or is it just that no-one has written acceptable code
> > yet?
> 
> AIO/DIO writes can indeed be non-blocking, if the file system doesn't
> need to do any metadata operations.  So if the file is preallocated,
> you should be able to issue an async DIO write without losing the CPU.

Well, there are couple ifs though. You can still block on locks, memory
allocation, or IO request allocation...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

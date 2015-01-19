Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 71D076B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 12:32:55 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id y10so26287878pdj.13
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 09:32:55 -0800 (PST)
Received: from mail.samba.org (fn.samba.org. [2001:470:1f05:1a07::1])
        by mx.google.com with ESMTPS id xg5si1177456pbc.77.2015.01.19.09.32.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 09:32:54 -0800 (PST)
Date: Mon, 19 Jan 2015 09:32:57 -0800
From: Jeremy Allison <jra@samba.org>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Message-ID: <20150119173257.GA14079@jeremy-HP>
Reply-To: Jeremy Allison <jra@samba.org>
References: <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP>
 <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
 <54BD234F.3060203@kernel.dk>
 <1421682581.2080.22.camel@HansenPartnership.com>
 <20150119164857.GC12308@jeremy-HP>
 <1421688414.2080.38.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421688414.2080.38.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jeremy Allison <jra@samba.org>, Jens Axboe <axboe@kernel.dk>, Volker Lendecke <Volker.Lendecke@sernet.de>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Milosz Tanski <milosz@adfin.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 09:26:54AM -0800, James Bottomley wrote:
> 
> Actually, it might be better to *resolve* the problem before people
> notice ... if the combination is considered useful, of course.

Oh sure - no arguments from me there !

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

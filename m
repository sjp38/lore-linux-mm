Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D6EAF6B0032
	for <linux-mm@kvack.org>; Mon, 19 Jan 2015 11:10:33 -0500 (EST)
Received: by mail-wg0-f47.google.com with SMTP id n12so2510161wgh.6
        for <linux-mm@kvack.org>; Mon, 19 Jan 2015 08:10:33 -0800 (PST)
Received: from mail.SerNet.de (mail.SerNet.de. [193.175.80.2])
        by mx.google.com with ESMTPS id wo6si26718070wjc.129.2015.01.19.08.10.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Mon, 19 Jan 2015 08:10:32 -0800 (PST)
Date: Mon, 19 Jan 2015 17:10:03 +0100
From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] async buffered diskio read for userspace
 apps
Reply-To: Volker.Lendecke@SerNet.DE
References: <CANP1eJF77=iH_tm1y0CgF6PwfhUK6WqU9S92d0xAnCt=WhZVfQ@mail.gmail.com>
 <20150115223157.GB25884@quack.suse.cz>
 <CANP1eJGRX4w56Ek4j7d2U+F7GNWp6RyOJonxKxTy0phUCpBM9g@mail.gmail.com>
 <20150116165506.GA10856@samba2>
 <CANP1eJEF33gndXeBJ0duP2_Bvuv-z6k7OLyuai7vjVdVKRYUWw@mail.gmail.com>
 <20150119071218.GA9747@jeremy-HP>
 <1421652849.2080.20.camel@HansenPartnership.com>
 <CANP1eJHYUprjvO1o6wfd197LM=Bmhi55YfdGQkPT0DKRn3=q6A@mail.gmail.com>
 <54BD234F.3060203@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54BD234F.3060203@kernel.dk>
Message-Id: <E1YDEuL-000mD3-8B@intern.SerNet.DE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Milosz Tanski <milosz@adfin.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Jeremy Allison <jra@samba.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org

On Mon, Jan 19, 2015 at 08:31:27AM -0700, Jens Axboe wrote:
> I didn't look at your code yet, but I'm assuming it's a self
> contained IO engine. So we should be able to make that work, by only
> linking the engine itself against libsmbclient. But sheesh, what a
> pain in the butt, why can't we just all be friends.

The published libsmbclient API misses the async features
that are needed here. Milosz needs to go lower-level.

Volker

-- 
SerNet GmbH, Bahnhofsallee 1b, 37081 Gottingen
phone: +49-551-370000-0, fax: +49-551-370000-9
AG Gottingen, HRB 2816, GF: Dr. Johannes Loxen
http://www.sernet.de, mailto:kontakt@sernet.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

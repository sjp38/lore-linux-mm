Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 7D6E06B0005
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 17:34:11 -0500 (EST)
Date: Mon, 11 Feb 2013 23:34:05 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 1/2] add helper for highmem checks
Message-ID: <20130211223405.GF2683@pd.tnic>
References: <20130208202813.62965F25@kernel.stglabs.ibm.com>
 <20130209094121.GB17728@pd.tnic>
 <20130209104751.GC17728@pd.tnic>
 <51192B39.9060501@linux.vnet.ibm.com>
 <20130211182826.GE2683@pd.tnic>
 <7794bbcd-5d5a-4e81-87fd-68b0aa17a556@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <7794bbcd-5d5a-4e81-87fd-68b0aa17a556@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, tglx@linutronix.de

On Mon, Feb 11, 2013 at 11:44:12AM -0800, H. Peter Anvin wrote:
> Oh, craptastic. X used to hash /dev/mem to get a random seed. It
> should have stopped that long ago, and used /dev/[u]random.

That's because debian still has this WINGs window manager which hasn't
seen any new releases since 2005: http://voins.program.ru/wdm/ and I'm
using it because I don't want the pompous crap of the other display
managers.

But this one uses /dev/mem as a randomFile only by default - there's a
configuration variable DisplayManager.randomFile which can be pointed
away from /dev/mem so that's easily fixable.

Mind you, I wouldnt've caught the issue if I wasn't using this ancient
thing in its default settings :o).

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

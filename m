Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 512626B0088
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 18:36:02 -0500 (EST)
Received: by iyj17 with SMTP id 17so2748701iyj.14
        for <linux-mm@kvack.org>; Mon, 20 Dec 2010 15:36:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101220103307.GA22986@infradead.org>
References: <cover.1292604745.git.minchan.kim@gmail.com>
	<20101220103307.GA22986@infradead.org>
Date: Tue, 21 Dec 2010 08:36:01 +0900
Message-ID: <AANLkTikss0RW_xRrD_vVvfqy1rH+NC=WPUB2qKBaw5qo@mail.gmail.com>
Subject: Re: [RFC 0/5] Change page reference hanlding semantic of page cache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Dec 20, 2010 at 7:33 PM, Christoph Hellwig <hch@infradead.org> wrote:
> You'll need to merge all patches into one, otherwise you create really
> nasty memory leaks when bisecting between them.
>

Okay. I will resend.

Thanks for the notice, Christoph.



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

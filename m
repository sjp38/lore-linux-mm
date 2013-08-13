Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id EFE5C6B0032
	for <linux-mm@kvack.org>; Tue, 13 Aug 2013 19:55:22 -0400 (EDT)
Received: by mail-vc0-f171.google.com with SMTP id ij15so4565650vcb.16
        for <linux-mm@kvack.org>; Tue, 13 Aug 2013 16:55:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130813231020.GA22667@asylum.americas.sgi.com>
References: <1375465467-40488-1-git-send-email-nzimmer@sgi.com>
	<1376344480-156708-1-git-send-email-nzimmer@sgi.com>
	<CA+55aFwTQLexJkf67P0b7Z7cw8fePjdDSdA4SOkM+Jf+kBPYEA@mail.gmail.com>
	<520A6DFC.1070201@sgi.com>
	<CA+55aFwRHdQ_f6ryUU1yWkW1Qz8cG958jLZuyhd_YdOq4-rfRA@mail.gmail.com>
	<20130813231020.GA22667@asylum.americas.sgi.com>
Date: Tue, 13 Aug 2013 16:55:21 -0700
Message-ID: <CA+55aFyeEK6FfNC-7SjGdYVrjiES0V7JNUG==P5p6iu+UNiAfA@mail.gmail.com>
Subject: Re: [RFC v3 0/5] Transparent on-demand struct page initialization
 embedded in the buddy allocator
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Zimmer <nzimmer@sgi.com>
Cc: Mike Travis <travis@sgi.com>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Rob Landley <rob@landley.net>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

On Tue, Aug 13, 2013 at 4:10 PM, Nathan Zimmer <nzimmer@sgi.com> wrote:
>
> The only mm structure we are adding to is a new flag in page->flags.
> That didn't seem too much.

I don't agree.

I see only downsides, and no upsides. Doing the same thing *without*
the downsides seems straightforward, so I simply see no reason for any
extra flags or tests at runtime.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

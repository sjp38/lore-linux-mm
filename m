Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id E1B016B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 06:51:33 -0400 (EDT)
Received: by layy10 with SMTP id y10so26327782lay.0
        for <linux-mm@kvack.org>; Wed, 13 May 2015 03:51:33 -0700 (PDT)
Received: from forward-corp1g.mail.yandex.net (forward-corp1g.mail.yandex.net. [95.108.253.251])
        by mx.google.com with ESMTPS id o4si12117908laj.143.2015.05.13.03.51.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 May 2015 03:51:32 -0700 (PDT)
Message-ID: <55532CB0.6070400@yandex-team.ru>
Date: Wed, 13 May 2015 13:51:28 +0300
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] pagemap: add mmap-exclusive bit for marking pages
 mapped only here
References: <20150512090156.24768.2521.stgit@buzz>	<20150512094303.24768.10282.stgit@buzz> <CAEVpBaLm9eicuFPmyRLa7GddLwtBJh3XzHT=fxj-h0YwwmXQOg@mail.gmail.com>
In-Reply-To: <CAEVpBaLm9eicuFPmyRLa7GddLwtBJh3XzHT=fxj-h0YwwmXQOg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Williamson <mwilliamson@undo-software.com>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, kernel list <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@parallels.com>, Linux API <linux-api@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Vlastimil Babka <vbabka@suse.cz>, Pavel Machek <pavel@ucw.cz>, Mark Seaborn <mseaborn@chromium.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, Daniel James <djames@undo-software.com>, Finn Grimwood <fgrimwood@undo-software.com>

On 12.05.2015 15:05, Mark Williamson wrote:
> Hi Konstantin,
>
> I hope you won't mind me thinking out loud here on the idea of adding
> a flag to the v2 pagemap fields...  From a kernel PoV, I agree that
> this seems like the cleanest approach.  However, with my application
> developer hat on:
>
>   1. I was hoping we'd be able to backport a compatible fix to older
> kernels that might adopt the pagemap permissions change.  Using the V2
> format flags rules out doing this for kernels that are too old to have
> soft-dirty, I think.
 >
>   2. From our software's PoV, I feel it's worth noting that it doesn't
> strictly fix ABI compatibility, though I realise that's probably not
> your primary concern here.  We'll need to modify our code to write the
> clear_refs file but that change is OK for us if it's the preferred
> solution.
>
> In the patches I've been playing with, I was considering putting the
> Exclusive flag in the now-unused PFN field of the pagemap entries.
> Since we're specifically trying to work around for the lack of PFN
> information, would there be any appetite for mirroring this flag
> unconditionally into the now-empty PFN field (i.e. whether using v1 or
> v2 flags) when accessed by an unprivileged process?
>
> I realise it's ugly from a kernel PoV and I feel a little bad for
> suggesting it - but it would address points 1 and 2 for us (our
> existing code just looks for changes in the pagemap entry, so sticking
> the flag in there would cause it to do the right thing).
>
> I'm sorry to raise application-specific issues at this point; I
> appreciate that your primary concern is to improve the kernel and
> technically I like the approach that you've taken!  I'll try and
> provide more code-oriented feedback once I've tried out the changes.

I prefer to backport v2 format (except soft-dirty bit and clear_refs)
into older kernels. Page-shift bits are barely used so nobody will see
the difference.

-- 
Konstantin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

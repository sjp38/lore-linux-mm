Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 3C5E66B006C
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 03:23:11 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so1534907pad.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2013 00:23:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130606120455.bd86a4c0ac009482db80f634@canb.auug.org.au>
References: <20130606002636.6746F5A41AE@corp2gmr1-2.hot.corp.google.com>
	<20130606120455.bd86a4c0ac009482db80f634@canb.auug.org.au>
Date: Thu, 6 Jun 2013 09:23:10 +0200
Message-ID: <CAMuHMdUKvJBS9u4qjDDKRhAMv9ikrxYSBgobLSSDWL1VmeV9wA@mail.gmail.com>
Subject: Re: mmotm 2013-06-05-17-24 uploaded
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: mm-commits@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Linux-Next <linux-next@vger.kernel.org>

Hi Andrew,

On Thu, Jun 6, 2013 at 4:04 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> On Wed, 05 Jun 2013 17:26:36 -0700 akpm@linux-foundation.org wrote:
>>
>>   linux-next-git-rejects.patch
>
> We must figure out why you sometimes get rejects that I do not get when I
> import your series into a git tree.  However in this case you resolution
> is not quite right.  It leaves 2 continue statements in
> net/mac80211/iface.c at line 191 which will unconditionally short circuit
> the enclosing loop.  The version that will be in linux-next today is
> correct (and git did it automatically as part of the merge of the old
> linux-next tree).

Do you have "git rerere" enabled?

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

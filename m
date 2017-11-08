Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id B045144043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 16:09:31 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 134so6612773ioo.22
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 13:09:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e21sor3298181ite.71.2017.11.08.13.09.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 13:09:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1711082133410.1962@nanos>
References: <nycvar.YFH.7.76.1711082103320.6470@cbobk.fhfr.pm> <alpine.DEB.2.20.1711082133410.1962@nanos>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 8 Nov 2017 13:09:29 -0800
Message-ID: <CA+55aFz5Z8dfLp1swfOaEomH21mvCFEy=4w6L0cWska=He45FQ@mail.gmail.com>
Subject: Re: [PATCH] x86/mm: Unbreak modules that rely on external PAGE_KERNEL availability
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Jiri Kosina <jikos@kernel.org>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Borislav Petkov <bp@suse.de>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Greg KH <greg@kroah.com>

On Wed, Nov 8, 2017 at 12:47 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
>
> Despised-by: Thomas Gleixner <tglx@linutronix.de>

So I despise the patch for a different reason: I hate it when we
export data symbols like this.

But that's independent of the GPL-vs-not issue, and it's not like this
is the first time it happens.

Generally we should export _functionality_, not data.

The fact that we need to export access to some random global data that
we then use in an inline function or macro to me says that the code
was not designed right to begin with.

But yeah, I guess we can't fix that easily as-is, and people who just
randomly slap _GPL() on the export should stop doing that. It's *not*
a default thing, quite the reverse. It should be something that is so
core - but also so _meaningful_ - that using it is a big flag that
you're not just a random driver or something.

So slapping _GPL on some random piece of data that that doesn't
actually imply anything at all for copyright derivation is
fundamentally broken and stupid.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

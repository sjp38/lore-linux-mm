Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 09CC86B0253
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 14:03:46 -0400 (EDT)
Received: by obbda8 with SMTP id da8so14300054obb.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:03:45 -0700 (PDT)
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com. [209.85.214.174])
        by mx.google.com with ESMTPS id p187si1704861oih.136.2015.09.22.11.03.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Sep 2015 11:03:45 -0700 (PDT)
Received: by obbda8 with SMTP id da8so14299769obb.1
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 11:03:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CA+55aFz2YH6F1L7JULQZOUMqyqeR+2LL2GWeg+QV1T8aRkJw1w@mail.gmail.com>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
 <1442903021-3893-2-git-send-email-mingo@kernel.org> <CA+55aFz2YH6F1L7JULQZOUMqyqeR+2LL2GWeg+QV1T8aRkJw1w@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 22 Sep 2015 11:03:25 -0700
Message-ID: <CALCETrV-Y90=wXOuXGauT0BQbyHdkpfLmi1nF5Y2G=Vhx3GzuA@mail.gmail.com>
Subject: Re: [PATCH 01/11] x86/mm/pat: Don't free PGD entries on memory unmap
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

On Tue, Sep 22, 2015 at 10:41 AM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> On Mon, Sep 21, 2015 at 11:23 PM, Ingo Molnar <mingo@kernel.org> wrote:
>>
>> This complicates PGD management, so don't do this. We can keep the
>> PGD mapped and the PUD table all clear - it's only a single 4K page
>> per 512 GB of memory mapped.
>
> I'm ok with this just from a "it removes code" standpoint.  That said,
> some of the other patches here make me go "hmm". I'll answer them
> separately.
>

If we want to get rid of vmalloc faults, then this patch makes it much
more obvious that it can be done without hurting performance.

>                   Linus



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

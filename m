Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 1E04C6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 19:56:47 -0400 (EDT)
Received: by mail-qc0-f176.google.com with SMTP id n41so1967702qco.7
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 16:56:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130409151906.2ee55116ca9e3abd80a90e3e@linux-foundation.org>
References: <20130408190738.GC2321@localhost.localdomain> <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
 <20130408210039.GA3396@localhost.localdomain> <20130409151906.2ee55116ca9e3abd80a90e3e@linux-foundation.org>
From: Andrew Shewmaker <agshew@gmail.com>
Date: Tue, 9 Apr 2013 17:56:25 -0600
Message-ID: <CAF-E8XEq9AE0z472QMWPbY-8YgvDsjx3FhEKRsVx7Bc_=AEn_Q@mail.gmail.com>
Subject: Re: [PATCH v8 3/3] mm: reinititalise user and admin reserves if
 memory is added or removed
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, Simon Jeons <simon.jeons@gmail.com>, ric.masonn@gmail.com

On Tue, Apr 9, 2013 at 4:19 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 8 Apr 2013 17:00:40 -0400 Andrew Shewmaker <agshew@gmail.com> wrote:
>
>> Should I add the memory notifier code to mm/nommu.c too?
>> I'm guessing that if a system doesn't have an mmu that it also
>> won't be hotplugging memory.
>
> I doubt if we need to worry about memory hotplug on nommu machines,
> so just do the minimum which is required to get nommu to compile
> and link.  That's probably "nothing".

I haven't gotten myself set up to compile a nommu architecture, so I'll post
my next version, and work on verifying it compiles and links later. But I
I probably won't be able to get to that for a week and a half ... I'm leaving
on my honeymoon in the next couple days :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

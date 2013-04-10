Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id E601E6B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 11:56:41 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id z24so263280qcq.19
        for <linux-mm@kvack.org>; Wed, 10 Apr 2013 08:56:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130409151906.2ee55116ca9e3abd80a90e3e@linux-foundation.org>
References: <20130408190738.GC2321@localhost.localdomain> <20130408133712.bd327017dec19a2c14e22662@linux-foundation.org>
 <20130408210039.GA3396@localhost.localdomain> <20130409151906.2ee55116ca9e3abd80a90e3e@linux-foundation.org>
From: Andrew Shewmaker <agshew@gmail.com>
Date: Wed, 10 Apr 2013 09:56:20 -0600
Message-ID: <CAF-E8XHdkqCUJf28z9GMBNUE84Murdsk=T-CoXoXgkLyrwk2-A@mail.gmail.com>
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

I don't know why I didn't think to look for a cross-compiler package first.
Anyway, nommu compiles and links without error when I disable suspend and
switch from slub to slab. Those errors didn't appear to have anything to do
with mm/nommu.c


--
Andrew Shewmaker

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

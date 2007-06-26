Received: by nz-out-0506.google.com with SMTP id x7so1560483nzc
        for <linux-mm@kvack.org>; Mon, 25 Jun 2007 17:08:03 -0700 (PDT)
Message-ID: <6934efce0706251708h7ab8d7dal6682def601a82073@mail.gmail.com>
Date: Mon, 25 Jun 2007 17:08:02 -0700
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: vm/fs meetup in september?
In-Reply-To: <20070624042345.GB20033@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070624042345.GB20033@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> A few things I'd like to talk about are:
>
> - the address space operations APIs, and their page based nature. I think
>   it would be nice to generally move toward offset,length based ones as
>   much as possible because it should give more efficiency and flexibility
>   in the filesystem.
>
> - write_begin API if it is still an issue by that date. Hope not :)
>
> - truncate races
>
> - fsblock if it hasn't been shot down by then
>
> - how to make complex API changes without having to fix most things
>   yourself.

I'd like to add:

-revamping filemap_xip.c

-memory mappable swap file (I'm not sure if this one is appropriate
for the proposed meeting)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

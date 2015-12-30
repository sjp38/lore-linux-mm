Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 2B6266B025E
	for <linux-mm@kvack.org>; Wed, 30 Dec 2015 01:20:57 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id o124so197961905oia.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 22:20:57 -0800 (PST)
Received: from mail-oi0-x22b.google.com (mail-oi0-x22b.google.com. [2607:f8b0:4003:c06::22b])
        by mx.google.com with ESMTPS id k82si27013590oia.120.2015.12.29.22.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Dec 2015 22:20:56 -0800 (PST)
Received: by mail-oi0-x22b.google.com with SMTP id o124so197961827oia.1
        for <linux-mm@kvack.org>; Tue, 29 Dec 2015 22:20:56 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151229212420.004b315f@lemur>
References: <20151229212420.004b315f@lemur>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 29 Dec 2015 22:20:36 -0800
Message-ID: <CALCETrXTaqTa-1YTrmsvNY1fvv0CMkQNVn+zVWp4ipT06v=4wQ@mail.gmail.com>
Subject: Re: reliably detect writes to a file: mmap, mtime, ...
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Uecker <muecker@gwdg.de>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

On Dec 30, 2015 4:24 AM, "Martin Uecker" <muecker@gwdg.de> wrote:
>
>
>
> Hi all,
>
> I want to reliably detect changes to a file even when
> written to using mmap. Surprisingly, there seems to be
> no API which would make this possible. Or at least I
> haven't found a way to do it...
>
>
> I looked at:
>
> - mtime. What is missing here is an API which would
> force mtime to be updated if there are dirty PTEs
> in some mapping (which need to be cleared/transferred
> to struct page at this point). This would allow to
> reliably detect changes to the file. If I understand it
> correctly, there was patch from Andy Lutomirski which
> made msync(ASYNC) do exactly this:
>
> http://oss.sgi.com/archives/xfs/2013-08/msg00748.html
>
> But it seems this never got in. The other problem with
> this is that mtime has limited granularity.
> (but maybe that could be worked around by having some
> kind of counter + API which tells how often mtime has
> been updated without changing its nominal value)

Those patches plus nanosecond granularity should do it, I think.  I
keep meaning to dust them off.  You could do it :)

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

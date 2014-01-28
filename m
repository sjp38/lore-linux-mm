Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f176.google.com (mail-vc0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 100C76B0031
	for <linux-mm@kvack.org>; Tue, 28 Jan 2014 12:30:48 -0500 (EST)
Received: by mail-vc0-f176.google.com with SMTP id la4so434748vcb.21
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 09:30:47 -0800 (PST)
Received: from mail-vb0-f48.google.com (mail-vb0-f48.google.com [209.85.212.48])
        by mx.google.com with ESMTPS id xw5si6586081vec.8.2014.01.28.09.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jan 2014 09:30:46 -0800 (PST)
Received: by mail-vb0-f48.google.com with SMTP id q16so425224vbe.21
        for <linux-mm@kvack.org>; Tue, 28 Jan 2014 09:30:46 -0800 (PST)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 28 Jan 2014 09:30:25 -0800
Message-ID: <CALCETrV2mtkKCMp6H+5gzoxi9kj9mx0GgsfiXqgn53AikCzFMw@mail.gmail.com>
Subject: [LSF/MM ATTEND] Other tracks I'm interested in (was Re: Persistent memory)
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jan 16, 2014 at 4:56 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> I'm interested in a persistent memory track.  There seems to be plenty
> of other emails about this, but here's my take:

I should add that I'm also interested in topics relating to the
performance of mm and page cache under various abusive workloads.
These include database-like things and large amounts of locked memory.

I'm not particularly qualified as a developer for page cache in
general, but I can certainly bang on things and run software that
tends to abuse systems.

If anyone wants to discuss working on mmap_sem contention or why
systems go out to lunch when a lot of memory is quickly dirtied, I'd
be very interested.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

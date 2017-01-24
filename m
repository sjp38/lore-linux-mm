Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 647096B026F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 15:17:32 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id z134so78189805lff.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:17:32 -0800 (PST)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id y30si13227940lfj.327.2017.01.24.12.17.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 12:17:30 -0800 (PST)
Received: by mail-lf0-x241.google.com with SMTP id x1so18689291lff.0
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 12:17:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1485216185.5952.2.camel@list.ru>
References: <bug-192571-27@https.bugzilla.kernel.org/> <bug-192571-27-qFfm1cXEv4@https.bugzilla.kernel.org/>
 <20170117122249.815342d95117c3f444acc952@linux-foundation.org>
 <20170118013948.GA580@jagdpanzerIV.localdomain> <1484719121.25232.1.camel@list.ru>
 <CALZtONBaJ0JJ+KBiRhRxh0=JWrfdVOsK_ThGE7hyyNPp2zFLrw@mail.gmail.com> <1485216185.5952.2.camel@list.ru>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 24 Jan 2017 15:16:49 -0500
Message-ID: <CALZtONAtjv1fjfVX2d5MKf2HY-kUtSDvA-m7pDbHW+ry2+OhAg@mail.gmail.com>
Subject: Re: [Bug 192571] zswap + zram enabled BUG
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandr <sss123next@list.ru>
Cc: bugzilla-daemon@bugzilla.kernel.org, Linux-MM <linux-mm@kvack.org>

On Mon, Jan 23, 2017 at 7:03 PM, Alexandr <sss123next@list.ru> wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA512
>
>
>> Why would you do this?  There's no benefit of using zswap together
>> with zram.
>
> i just wanted to test zram and zswap, i still not dig to deep in it,
> but what i wanted is to use zram swap (with zswap disabled), and if it
> exceeded use real swap on block device with zswap enabled.

I don't believe that's possible, you can't enable zswap for only
specific swap devices; and anyway, if you fill up zram, you won't
really have any memory left for zswap to use will you?

However, it shouldn't encounter any BUG(), like you saw.  If it's
reproducable for you, can you give details on how to reproduce it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

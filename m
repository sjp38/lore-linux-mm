Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBD636B0253
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 14:38:48 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id r94so11953221ioe.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:38:48 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id u125si3218814itd.17.2016.11.22.11.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 11:38:48 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id h133so11552086ioe.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 11:38:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
References: <20161121154336.GD19750@merlins.org> <0d4939f3-869d-6fb8-0914-5f74172f8519@suse.cz>
 <20161121215639.GF13371@merlins.org> <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 22 Nov 2016 11:38:47 -0800
Message-ID: <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Marc MERLIN <marc@merlins.org>, linux-mm <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, Nov 22, 2016 at 8:14 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> Thanks a lot for the testing. So what do we do now about 4.8? (4.7 is
> already EOL AFAICS).
>
> - send the patch [1] as 4.8-only stable.

I think that's the right thing to do. It's pretty small, and the
argument that it changes the oom logic too much is pretty bogus, I
think. The oom logic in 4.8 is simply broken. Let's get it fixed.
Changing it is the point.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

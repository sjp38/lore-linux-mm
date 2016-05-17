Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F78D6B0253
	for <linux-mm@kvack.org>; Tue, 17 May 2016 05:03:49 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id y84so5584182lfc.3
        for <linux-mm@kvack.org>; Tue, 17 May 2016 02:03:49 -0700 (PDT)
Received: from smtp2-g21.free.fr (smtp2-g21.free.fr. [2a01:e0c:1:1599::11])
        by mx.google.com with ESMTPS id z10si25149434wmd.113.2016.05.17.02.03.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 02:03:48 -0700 (PDT)
Subject: Re: [PATCH] mm: add config option to select the initial overcommit
 mode
References: <5731CC6E.3080807@laposte.net>
From: Mason <slash.tmp@free.fr>
Message-ID: <573ADE6C.4040804@free.fr>
Date: Tue, 17 May 2016 11:03:40 +0200
MIME-Version: 1.0
In-Reply-To: <5731CC6E.3080807@laposte.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Frias <sf84@laposte.net>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 10/05/2016 13:56, Sebastian Frias wrote:

> Currently the initial value of the overcommit mode is OVERCOMMIT_GUESS.
> However, on embedded systems it is usually better to disable overcommit
> to avoid waking up the OOM-killer and its well known undesirable
> side-effects.

There is an interesting article on LWN:

Toward more predictable and reliable out-of-memory handling
https://lwn.net/Articles/668126/

Regards.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

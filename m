Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 09AD76B0062
	for <linux-mm@kvack.org>; Wed, 16 Jul 2014 06:09:15 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so991685pdj.28
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 03:09:15 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id qi10si14055738pbc.198.2014.07.16.03.09.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Jul 2014 03:09:14 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id et14so1045416pad.21
        for <linux-mm@kvack.org>; Wed, 16 Jul 2014 03:09:14 -0700 (PDT)
Date: Wed, 16 Jul 2014 03:07:37 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3 4/7] selftests: add memfd_create() + sealing tests
In-Reply-To: <1402655819-14325-5-git-send-email-dh.herrmann@gmail.com>
Message-ID: <alpine.LSU.2.11.1407160307160.1775@eggly.anvils>
References: <1402655819-14325-1-git-send-email-dh.herrmann@gmail.com> <1402655819-14325-5-git-send-email-dh.herrmann@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Herrmann <dh.herrmann@gmail.com>
Cc: linux-kernel@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>, Ryan Lortie <desrt@desrt.ca>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, Greg Kroah-Hartman <greg@kroah.com>, john.stultz@linaro.org, Lennart Poettering <lennart@poettering.net>, Daniel Mack <zonque@gmail.com>, Kay Sievers <kay@vrfy.org>, Hugh Dickins <hughd@google.com>, Tony Battersby <tonyb@cybernetics.com>, Andy Lutomirski <luto@amacapital.net>

On Fri, 13 Jun 2014, David Herrmann wrote:

> Some basic tests to verify sealing on memfds works as expected and
> guarantees the advertised semantics.
> 
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

Thanks for whatever the fix was, I didn't hit any problem running
this version repeatedly, on 64-bit and on 32-bit.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

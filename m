Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 122CC6B0072
	for <linux-mm@kvack.org>; Sun, 14 Dec 2014 16:47:35 -0500 (EST)
Received: by mail-qg0-f49.google.com with SMTP id a108so7717735qge.36
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 13:47:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141214202224.GH2672@kvack.org>
References: <20141214202224.GH2672@kvack.org>
Date: Sun, 14 Dec 2014 13:47:32 -0800
Message-ID: <CA+55aFxV2h1NrE87Zt7U8bsrXgeO=Tf-DyQO8wBYZ=M7WEjxKg@mail.gmail.com>
Subject: Re: [GIT PULL] aio: changes for 3.19
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: linux-aio@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, Dec 14, 2014 at 12:22 PM, Benjamin LaHaise <bcrl@kvack.org> wrote:
>
> Pavel Emelyanov (1):
>       aio: Make it possible to remap aio ring

So quite frankly, I think this should have had more acks from VM
people. The patch looks ok to me, but it took me by surprise, and I
don't see much any discussion about it on linux-mm either..

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

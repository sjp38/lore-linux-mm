Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 532D16B00E8
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 11:06:39 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id wy17so6066282pbc.28
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 08:06:38 -0800 (PST)
Received: from psmtp.com ([74.125.245.161])
        by mx.google.com with SMTP id hk1si2121539pbb.11.2013.11.06.08.06.37
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 08:06:38 -0800 (PST)
Received: by mail-ie0-f171.google.com with SMTP id tp5so17817700ieb.16
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 08:06:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52715AD1.7000703@gmx.de>
References: <526696BF.6050909@gmx.de>
	<CAFLxGvy3NeRKu+KQCCm0j4LS60PYhH0bC8WWjfiPvpstPBjAkA@mail.gmail.com>
	<5266A698.10400@gmx.de>
	<5266B60A.1000005@nod.at>
	<52715AD1.7000703@gmx.de>
Date: Wed, 6 Nov 2013 20:06:36 +0400
Message-ID: <CALYGNiPvJF1u8gXNcX1AZR5-VkGqJnaose84KBbdaoBAq8aoGQ@mail.gmail.com>
Subject: Re: [uml-devel] fuzz tested 32 bit user mode linux image hangs in radix_tree_next_chunk()
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>
Cc: Richard Weinberger <richard@nod.at>, Richard Weinberger <richard.weinberger@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, UML devel <user-mode-linux-devel@lists.sourceforge.net>

In this case it must stop after scanning whole tree in line:
/* Overflow after ~0UL */
if (!index)
  return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

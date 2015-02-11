Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 45C9D6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 22:49:28 -0500 (EST)
Received: by iecar1 with SMTP id ar1so1239522iec.11
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 19:49:28 -0800 (PST)
Received: from mail-ig0-x22f.google.com (mail-ig0-x22f.google.com. [2607:f8b0:4001:c05::22f])
        by mx.google.com with ESMTPS id j2si10680609igx.32.2015.02.10.19.49.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 19:49:27 -0800 (PST)
Received: by mail-ig0-f175.google.com with SMTP id hn18so28283759igb.2
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 19:49:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20150211034307.GA2932@kroah.com>
References: <20150203231211.486950145@linuxfoundation.org>
	<20150203231212.223123220@linuxfoundation.org>
	<CALYGNiPVvgxMFyDTSFv4mUhkq-5Q+Gp2UEY5W9G0gEc8YajipQ@mail.gmail.com>
	<20150211034307.GA2932@kroah.com>
Date: Tue, 10 Feb 2015 19:49:27 -0800
Message-ID: <CA+55aFxWCxq59cfG9Uvm3AAx9MngWENjz1oRayPQMb8+8pVnMA@mail.gmail.com>
Subject: Re: [PATCH 3.18 04/57] vm: add VM_FAULT_SIGSEGV handling support
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stable <stable@vger.kernel.org>, Jan Engelhardt <jengelh@inai.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 10, 2015 at 7:43 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> Ah, nice, I missed that one.

Ugh, to be fair, I missed it too.

The alternative to backporting 7fb08eca4527 is to make the backport of
commit 33692f27597f use "bad_area()" instead of
"bad_area_nosemaphore()".

                    Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

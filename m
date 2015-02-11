Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id CE6456B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 23:17:06 -0500 (EST)
Received: by pdjy10 with SMTP id y10so1537178pdj.13
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 20:17:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id uv4si29138102pbc.110.2015.02.10.20.17.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 20:17:06 -0800 (PST)
Date: Wed, 11 Feb 2015 12:16:56 +0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.18 04/57] vm: add VM_FAULT_SIGSEGV handling support
Message-ID: <20150211041656.GA26265@kroah.com>
References: <20150203231211.486950145@linuxfoundation.org>
 <20150203231212.223123220@linuxfoundation.org>
 <CALYGNiPVvgxMFyDTSFv4mUhkq-5Q+Gp2UEY5W9G0gEc8YajipQ@mail.gmail.com>
 <20150211034307.GA2932@kroah.com>
 <CA+55aFxWCxq59cfG9Uvm3AAx9MngWENjz1oRayPQMb8+8pVnMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxWCxq59cfG9Uvm3AAx9MngWENjz1oRayPQMb8+8pVnMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stable <stable@vger.kernel.org>, Jan Engelhardt <jengelh@inai.de>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 10, 2015 at 07:49:27PM -0800, Linus Torvalds wrote:
> On Tue, Feb 10, 2015 at 7:43 PM, Greg Kroah-Hartman
> <gregkh@linuxfoundation.org> wrote:
> >
> > Ah, nice, I missed that one.
> 
> Ugh, to be fair, I missed it too.
> 
> The alternative to backporting 7fb08eca4527 is to make the backport of
> commit 33692f27597f use "bad_area()" instead of
> "bad_area_nosemaphore()".

33692f27597f already showed up in 3.18.6, so I can't go back and change
that version :(

I'll just queue this one up, thanks.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

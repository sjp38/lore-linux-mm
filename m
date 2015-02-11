Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A4E2A6B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 22:43:17 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kx10so1233948pab.13
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 19:43:17 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u5si29104240pde.139.2015.02.10.19.43.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Feb 2015 19:43:16 -0800 (PST)
Date: Wed, 11 Feb 2015 11:43:07 +0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.18 04/57] vm: add VM_FAULT_SIGSEGV handling support
Message-ID: <20150211034307.GA2932@kroah.com>
References: <20150203231211.486950145@linuxfoundation.org>
 <20150203231212.223123220@linuxfoundation.org>
 <CALYGNiPVvgxMFyDTSFv4mUhkq-5Q+Gp2UEY5W9G0gEc8YajipQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALYGNiPVvgxMFyDTSFv4mUhkq-5Q+Gp2UEY5W9G0gEc8YajipQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stable <stable@vger.kernel.org>, Jan Engelhardt <jengelh@inai.de>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 10, 2015 at 12:22:41PM +0400, Konstantin Khlebnikov wrote:
> I've found regression:
> 
> [  257.139907] ================================================
> [  257.139909] [ BUG: lock held when returning to user space! ]
> [  257.139912] 3.18.6-debug+ #161 Tainted: G     U
> [  257.139914] ------------------------------------------------
> [  257.139916] python/22843 is leaving the kernel with locks still held!
> [  257.139918] 1 lock held by python/22843:
> [  257.139920]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8104e4c2>]
> __do_page_fault+0x162/0x570
> 
> upstream commit 7fb08eca45270d0ae86e1ad9d39c40b7a55d0190 must be backported too.

Ah, nice, I missed that one.  How did you test this?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

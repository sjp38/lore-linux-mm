Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9496B0062
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 16:48:33 -0400 (EDT)
Received: by mail-ve0-f174.google.com with SMTP id oz11so23011veb.33
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:48:32 -0700 (PDT)
Received: from mail-ve0-x229.google.com (mail-ve0-x229.google.com [2607:f8b0:400c:c01::229])
        by mx.google.com with ESMTPS id tz5si7083072vdc.151.2014.04.22.13.48.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 13:48:32 -0700 (PDT)
Received: by mail-ve0-f169.google.com with SMTP id pa12so24584veb.28
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 13:48:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
References: <20140422180308.GA19038@redhat.com>
	<CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com>
	<alpine.LSU.2.11.1404221303060.6220@eggly.anvils>
Date: Tue, 22 Apr 2014 13:48:32 -0700
Message-ID: <CA+55aFxs1eF7Wod0J_OUE+JRcfzZ99MEXhdtp8FjvxQKKUGZKw@mail.gmail.com>
Subject: Re: 3.15rc2 hanging processes on exit.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Tue, Apr 22, 2014 at 1:17 PM, Hugh Dickins <hughd@google.com> wrote:
>
> One nit: we're inconsistent, and shall never move VM_READ,VM_WRITE bits,
> but it would set a better example to declare "vm_flags_t vm_flags"
> in your patch below, instead of "unsigned vm_flags".

Ack. Will do. And I'll mark it for stable, since I agree that this
does not look like it would be a new case.

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

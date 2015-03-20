Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 04E336B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 16:01:19 -0400 (EDT)
Received: by pacwe9 with SMTP id we9so118583541pac.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:01:18 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bx6si11354827pdb.26.2015.03.20.13.01.17
        for <linux-mm@kvack.org>;
        Fri, 20 Mar 2015 13:01:18 -0700 (PDT)
Message-ID: <550C7C8C.2020309@intel.com>
Date: Fri, 20 Mar 2015 13:01:16 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: 4.0.0-rc4: panic in free_block
References: <550C37C9.2060200@oracle.com>	<CA+55aFxhNphSMrNvwqj0AQRzuqRdPG11J6DaazKWMb2U+H7wKg@mail.gmail.com>	<550C5078.8040402@oracle.com> <CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
In-Reply-To: <CA+55aFyQWa0PjT-3y-HB9P-UAzThrZme5gj1P6P6hMTTF9cMtA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, David Ahern <david.ahern@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, sparclinux@vger.kernel.org

On 03/20/2015 09:58 AM, Linus Torvalds wrote:
> 128 cpu's is still "unusual", of course, but by no means unheard of,
> and I'f have expected others to report it too if it was wasy to
> trigger on x86-64.

FWIW, I configured a kernel with SLAB and kicked off a bunch of compiles
on a 160-thread x86_64 system.  It definitely doesn't die _quickly_.
It's been running for an hour or two.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

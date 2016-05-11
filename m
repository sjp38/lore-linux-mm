Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2432F6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 01:59:58 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r12so32680201wme.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 22:59:58 -0700 (PDT)
Received: from mail-lf0-x230.google.com (mail-lf0-x230.google.com. [2a00:1450:4010:c07::230])
        by mx.google.com with ESMTPS id a10si4391543lbx.55.2016.05.10.22.59.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 22:59:56 -0700 (PDT)
Received: by mail-lf0-x230.google.com with SMTP id y84so38029205lfc.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 22:59:56 -0700 (PDT)
Date: Wed, 11 May 2016 08:59:54 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: Getting rid of dynamic TASK_SIZE (on x86, at least)
Message-ID: <20160511055954.GA2994@uranus.lan>
References: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
 <20160510163045.GH14377@uranus.lan>
 <CALCETrVFJN+ktqjGAMckVpUf3JA4_iJf2R1tXDG=WmwwwLEF-Q@mail.gmail.com>
 <20160510170545.GI14377@uranus.lan>
 <CALCETrWS5YpRMh00tH3Lx6yUNhzSti3kpema8nwv-d-jUKbGaA@mail.gmail.com>
 <20160510174915.GJ14377@uranus.lan>
 <CALCETrXm+zRxfq08PZUQSS7iMdDsqZYwHcNw6Q6J1qkYoJHSvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrXm+zRxfq08PZUQSS7iMdDsqZYwHcNw6Q6J1qkYoJHSvg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dmitry Safonov <0x7f454c46@gmail.com>, Ruslan Kabatsayev <b7.10110111@gmail.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Pavel Emelyanov <xemul@parallels.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, May 10, 2016 at 02:11:41PM -0700, Andy Lutomirski wrote:
 >
> > For sure page faulting must consider what kind of fault is it.
> > Or we gonna drop such code at all?
> 
> That code was bogus.  (Well, it was correct unless user code had a way
> to create a funny high mapping in an otherwise 32-bit task, but it
> still should have been TASK_SIZE_MAX.)  Fix sent.

OK, great!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

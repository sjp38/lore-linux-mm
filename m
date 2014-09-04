Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id 7B8696B0037
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 15:07:35 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id 131so6396579ykp.34
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 12:07:35 -0700 (PDT)
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com. [15.193.200.69])
        by mx.google.com with ESMTPS id w4si13683729yhn.100.2014.09.04.12.07.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 12:07:35 -0700 (PDT)
Message-ID: <1409857025.28990.125.camel@misato.fc.hp.com>
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Thu, 04 Sep 2014 12:57:05 -0600
In-Reply-To: <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
	 <1409855739-8985-5-git-send-email-toshi.kani@hp.com>
	 <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, 2014-09-04 at 11:57 -0700, Andy Lutomirski wrote:
> On Thu, Sep 4, 2014 at 11:35 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> > This patch adds set_memory_wt(), set_memory_array_wt(), and
> > set_pages_array_wt() for setting range(s) of memory to WT.
> >
> 
> Possibly dumb question: I thought that set_memory_xyz was only for
> RAM.  Is that incorrect?

It works for non-RAM ranges as well.  For instance, you can use
set_memory_xyz() to change cache attribute for a non-RAM range mapped by
ioremap_cache().

Thanks,
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

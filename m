Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id D82146B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 14:57:24 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id s7so12207199lbd.35
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 11:57:24 -0700 (PDT)
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
        by mx.google.com with ESMTPS id cf12si3884154lbb.19.2014.09.04.11.57.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 11:57:22 -0700 (PDT)
Received: by mail-lb0-f176.google.com with SMTP id s7so11929231lbd.7
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 11:57:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1409855739-8985-5-git-send-email-toshi.kani@hp.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com> <1409855739-8985-5-git-send-email-toshi.kani@hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 4 Sep 2014 11:57:01 -0700
Message-ID: <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, Sep 4, 2014 at 11:35 AM, Toshi Kani <toshi.kani@hp.com> wrote:
> This patch adds set_memory_wt(), set_memory_array_wt(), and
> set_pages_array_wt() for setting range(s) of memory to WT.
>

Possibly dumb question: I thought that set_memory_xyz was only for
RAM.  Is that incorrect?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

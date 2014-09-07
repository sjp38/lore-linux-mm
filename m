Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 364856B0035
	for <linux-mm@kvack.org>; Sun,  7 Sep 2014 04:49:36 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id w62so1109898wes.31
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 01:49:35 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
        by mx.google.com with ESMTPS id e12si9383707wik.70.2014.09.07.01.49.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Sep 2014 01:49:34 -0700 (PDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so1319806wiv.2
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 01:49:34 -0700 (PDT)
Message-ID: <540C1C01.1000308@plexistor.com>
Date: Sun, 07 Sep 2014 11:49:05 +0300
From: Yigal Korman <yigal@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>	 <1409855739-8985-5-git-send-email-toshi.kani@hp.com>	 <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com> <1409857025.28990.125.camel@misato.fc.hp.com>
In-Reply-To: <1409857025.28990.125.camel@misato.fc.hp.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>, Andy Lutomirski <luto@amacapital.net>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

I think that what confused Andy (or at least me) is the documentation in Documentation/x86/pat.txt
If it's possible, can you please update pat.txt as part of the patch?

Thank you,
Yigal

On 04/09/2014 21:57, Toshi Kani wrote:
> On Thu, 2014-09-04 at 11:57 -0700, Andy Lutomirski wrote:
>> On Thu, Sep 4, 2014 at 11:35 AM, Toshi Kani <toshi.kani@hp.com> wrote:
>>> This patch adds set_memory_wt(), set_memory_array_wt(), and
>>> set_pages_array_wt() for setting range(s) of memory to WT.
>>>
>> Possibly dumb question: I thought that set_memory_xyz was only for
>> RAM.  Is that incorrect?
> It works for non-RAM ranges as well.  For instance, you can use
> set_memory_xyz() to change cache attribute for a non-RAM range mapped by
> ioremap_cache().
>
> Thanks,
> -Toshi
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

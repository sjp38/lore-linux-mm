Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id 194A56B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 05:25:32 -0400 (EDT)
Received: by lbbpu9 with SMTP id pu9so95914582lbb.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:25:31 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id rv3si15547350lbb.151.2015.08.25.02.25.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 02:25:30 -0700 (PDT)
Received: by labia3 with SMTP id ia3so29717313lab.3
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 02:25:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com>
Date: Tue, 25 Aug 2015 12:25:29 +0300
Message-ID: <CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate use
 case please?
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hartshorn <jhartshorn@connexity.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon, Aug 24, 2015 at 11:12 PM, James Hartshorn
<jhartshorn@connexity.com> wrote:
> Hi,
>
>
> I've been struggling with transparent hugepage performance issues, and can't
> seem to find anyone who actually uses it intentionally.  Virtually every
> database that runs on linux however recommends disabling it or setting it to
> madvise.  I'm referring to:
>
>
> /sys/kernel/mm/transparent_hugepage/enabled
>
>
> I asked on the internet
> http://unix.stackexchange.com/questions/201906/does-anyone-actually-use-and-benefit-from-transparent-huge-pages
> and got no responses there.
>
>
>
> Independently I noticed
>
>
> "sysctl: The scan_unevictable_pages sysctl/node-interface has been disabled
> for lack of a legitimate use case.  If you have one, please send an email to
> linux-mm@kvack.org."
>
>
> And thought wow that's exactly what should be done to transparent hugepages.
>
>
> Thoughts?

THP works very well when system has a lot of free memory.
Probably default should be weakened to "only if we have tons of free memory".
For example allocate THP pages atomically, only if buddy allocator already
has huge pages. Also them could be pre-zeroed in background.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

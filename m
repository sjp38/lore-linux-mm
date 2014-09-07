Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id C58A56B0035
	for <linux-mm@kvack.org>; Sun,  7 Sep 2014 12:50:05 -0400 (EDT)
Received: by mail-lb0-f171.google.com with SMTP id 10so6723001lbg.16
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 09:50:04 -0700 (PDT)
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
        by mx.google.com with ESMTPS id w5si10815043lae.42.2014.09.07.09.50.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 07 Sep 2014 09:50:03 -0700 (PDT)
Received: by mail-la0-f52.google.com with SMTP id b8so4890214lan.39
        for <linux-mm@kvack.org>; Sun, 07 Sep 2014 09:50:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <540C1C01.1000308@plexistor.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-5-git-send-email-toshi.kani@hp.com> <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
 <1409857025.28990.125.camel@misato.fc.hp.com> <540C1C01.1000308@plexistor.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Sun, 7 Sep 2014 09:49:41 -0700
Message-ID: <CALCETrX-jsDBbPTVBLE=TkrfO9dLJgpog7TVKqi-wxxj6saRjA@mail.gmail.com>
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yigal Korman <yigal@plexistor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Sun, Sep 7, 2014 at 1:49 AM, Yigal Korman <yigal@plexistor.com> wrote:
> I think that what confused Andy (or at least me) is the documentation in Documentation/x86/pat.txt
> If it's possible, can you please update pat.txt as part of the patch?

Indeed.  That file seems to indicate several times that the intended
use of set_memory_xyz is for RAM.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

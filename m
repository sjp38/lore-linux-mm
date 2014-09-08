Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id B38B86B0037
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 13:24:03 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id c11so1712300lbj.37
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 10:24:02 -0700 (PDT)
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
        by mx.google.com with ESMTPS id e10si10037346lae.93.2014.09.08.10.24.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 10:24:01 -0700 (PDT)
Received: by mail-lb0-f178.google.com with SMTP id c11so1711787lbj.23
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 10:24:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1410188863.28990.209.camel@misato.fc.hp.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-5-git-send-email-toshi.kani@hp.com> <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
 <1409857025.28990.125.camel@misato.fc.hp.com> <540C1C01.1000308@plexistor.com>
 <CALCETrX-jsDBbPTVBLE=TkrfO9dLJgpog7TVKqi-wxxj6saRjA@mail.gmail.com> <1410188863.28990.209.camel@misato.fc.hp.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 8 Sep 2014 10:23:40 -0700
Message-ID: <CALCETrV4fJT5jo6uOpyfeEExeLQREZjJY5SafuMHt_mbzE55eA@mail.gmail.com>
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hp.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Yigal Korman <yigal@plexistor.com>, Juergen Gross <jgross@suse.com>, Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>, akpm@linuxfoundation.org, Ingo Molnar <mingo@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Stefan Bader <stefan.bader@canonical.com>

On Sep 8, 2014 8:18 AM, "Toshi Kani" <toshi.kani@hp.com> wrote:
>
> On Sun, 2014-09-07 at 09:49 -0700, Andy Lutomirski wrote:
> > On Sun, Sep 7, 2014 at 1:49 AM, Yigal Korman <yigal@plexistor.com> wrote:
> > > I think that what confused Andy (or at least me) is the documentation in Documentation/x86/pat.txt
> > > If it's possible, can you please update pat.txt as part of the patch?
> >
> > Indeed.  That file seems to indicate several times that the intended
> > use of set_memory_xyz is for RAM.
>
>
> Good point.  pat.txt is correct that the "intended" use of
> set_memory_xyz() is for RAM since there is no other way to set non-WB
> attribute for RAM.  For reserved memory, one should call ioremap_xyz()
> to map with the xyz attribute directly.  From the functionality POV,
> set_memory_xyz() works for reserved memory, but such usage is not
> intended.
>
> Should I drop the patch 4/5 until we can track the use of WT for RAM?

Probably not.  I can imagine someone ioremapping a huge chunk of
NV-DIMM and then wanting to change some of it to WT.  Unless I've
missed something (which is rather likely), the cleanest way to do this
is with set_memory_wt.

If that happens, someone should update pat.txt to indicate that it's allowed.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

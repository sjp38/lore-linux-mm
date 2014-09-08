Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f45.google.com (mail-oa0-f45.google.com [209.85.219.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1D7E56B0036
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 11:18:21 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id n16so10687353oag.4
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 08:18:17 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id c3si14696571oex.81.2014.09.08.08.18.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 08:18:16 -0700 (PDT)
Message-ID: <1410188863.28990.209.camel@misato.fc.hp.com>
Subject: Re: [PATCH 4/5] x86, mm: Add set_memory_wt() for WT
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 08 Sep 2014 09:07:43 -0600
In-Reply-To: <CALCETrX-jsDBbPTVBLE=TkrfO9dLJgpog7TVKqi-wxxj6saRjA@mail.gmail.com>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
	 <1409855739-8985-5-git-send-email-toshi.kani@hp.com>
	 <CALCETrXjpoVmCi07zo0dKH9LrF+nz9F3GshNiQvmiueFFH=TUQ@mail.gmail.com>
	 <1409857025.28990.125.camel@misato.fc.hp.com>
	 <540C1C01.1000308@plexistor.com>
	 <CALCETrX-jsDBbPTVBLE=TkrfO9dLJgpog7TVKqi-wxxj6saRjA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Yigal Korman <yigal@plexistor.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Sun, 2014-09-07 at 09:49 -0700, Andy Lutomirski wrote:
> On Sun, Sep 7, 2014 at 1:49 AM, Yigal Korman <yigal@plexistor.com> wrote:
> > I think that what confused Andy (or at least me) is the documentation in Documentation/x86/pat.txt
> > If it's possible, can you please update pat.txt as part of the patch?
> 
> Indeed.  That file seems to indicate several times that the intended
> use of set_memory_xyz is for RAM.


Good point.  pat.txt is correct that the "intended" use of
set_memory_xyz() is for RAM since there is no other way to set non-WB
attribute for RAM.  For reserved memory, one should call ioremap_xyz()
to map with the xyz attribute directly.  From the functionality POV,
set_memory_xyz() works for reserved memory, but such usage is not
intended.

Should I drop the patch 4/5 until we can track the use of WT for RAM?

Thanks,
-Toshi
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

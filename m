Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id C6E686B0075
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 10:23:16 -0500 (EST)
Received: by mail-la0-f46.google.com with SMTP id hs14so1082177lab.33
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 07:23:13 -0800 (PST)
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com. [209.85.215.50])
        by mx.google.com with ESMTPS id h3si1199173lbc.88.2014.11.04.07.23.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 07:23:11 -0800 (PST)
Received: by mail-la0-f50.google.com with SMTP id hz20so1056224lab.23
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 07:23:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <94D0CD8314A33A4D9D801C0FE68B40295936556E@G4W3202.americas.hpqcorp.net>
References: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
 <1414450545-14028-5-git-send-email-toshi.kani@hp.com> <94D0CD8314A33A4D9D801C0FE68B4029593578ED@G9W0745.americas.hpqcorp.net>
 <1415052905.10958.39.camel@misato.fc.hp.com> <alpine.DEB.2.11.1411032352161.5308@nanos>
 <CALCETrXs0SotEmqs0B7rbnnqkLvMV+fzOJzNbp+y2U=zB+25OQ@mail.gmail.com> <94D0CD8314A33A4D9D801C0FE68B40295936556E@G4W3202.americas.hpqcorp.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 4 Nov 2014 07:22:49 -0800
Message-ID: <CALCETrWAU+mH0Ss7jgKXcoS=wVet5o=hP2iqz9H15+KSyq=Y-A@mail.gmail.com>
Subject: Re: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for WT
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Server Storage)" <Elliott@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, "Kani, Toshimitsu" <toshi.kani@hp.com>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "arnd@arndb.de" <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jgross@suse.com" <jgross@suse.com>, "stefan.bader@canonical.com" <stefan.bader@canonical.com>, "hmh@hmh.eng.br" <hmh@hmh.eng.br>, "yigal@plexistor.com" <yigal@plexistor.com>, "konrad.wilk@oracle.com" <konrad.wilk@oracle.com>

On Mon, Nov 3, 2014 at 7:34 PM, Elliott, Robert (Server Storage)
<Elliott@hp.com> wrote:
>
>
>> -----Original Message-----
>> From: Andy Lutomirski [mailto:luto@amacapital.net]
>> Sent: Monday, November 03, 2014 5:01 PM
>> To: Thomas Gleixner
>> Cc: Kani, Toshimitsu; Elliott, Robert (Server Storage); hpa@zytor.com;
>> mingo@redhat.com; akpm@linux-foundation.org; arnd@arndb.de; linux-
>> mm@kvack.org; linux-kernel@vger.kernel.org; jgross@suse.com;
>> stefan.bader@canonical.com; hmh@hmh.eng.br; yigal@plexistor.com;
>> konrad.wilk@oracle.com
>> Subject: Re: [PATCH v4 4/7] x86, mm, pat: Add pgprot_writethrough() for
>> WT
>>
>> On Mon, Nov 3, 2014 at 2:53 PM, Thomas Gleixner <tglx@linutronix.de>
>> wrote:
> ...
>> On the other hand, I thought that _GPL was supposed to be more about
>> whether the thing using it is inherently a derived work of the Linux
>> kernel.  Since WT is an Intel concept, not a Linux concept, then I
>> think that this is a hard argument to make.
>
> IBM System/360 Model 85 (1968) had write-through (i.e., store-through)
> caching.  Intel might claim Write Combining, though.
>

Arguably WC is, and was, mostly a hack to enable full cacheline writes
without an instruction to do it directly.  x86 has such an instruction
now, so WC is less necessary.

In any event, my point wasn't that Intel should get any particular
credit here; it's that this is really a straightforward interface to
program a hardware feature that predates the interface.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

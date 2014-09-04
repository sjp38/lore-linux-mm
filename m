Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id BFD2E6B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 19:35:06 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hz20so12873890lab.17
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 16:35:05 -0700 (PDT)
Received: from mail-la0-f49.google.com (mail-la0-f49.google.com [209.85.215.49])
        by mx.google.com with ESMTPS id g9si504016lbv.86.2014.09.04.16.35.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 16:35:04 -0700 (PDT)
Received: by mail-la0-f49.google.com with SMTP id b17so12748532lan.22
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 16:35:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140904231923.GA15320@khazad-dum.debian.net>
References: <1409855739-8985-1-git-send-email-toshi.kani@hp.com>
 <1409855739-8985-2-git-send-email-toshi.kani@hp.com> <20140904201123.GA9116@khazad-dum.debian.net>
 <5408C9C4.1010705@zytor.com> <20140904231923.GA15320@khazad-dum.debian.net>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 4 Sep 2014 16:34:43 -0700
Message-ID: <CALCETrWxKFtM8FhnHQz--uaHYbiqShE1XLJxMCKN7Rs4SO14eQ@mail.gmail.com>
Subject: Re: [PATCH 1/5] x86, mm, pat: Set WT to PA4 slot of PAT MSR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Toshi Kani <toshi.kani@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, akpm@linuxfoundation.org, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Juergen Gross <jgross@suse.com>, Stefan Bader <stefan.bader@canonical.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

On Thu, Sep 4, 2014 at 4:19 PM, Henrique de Moraes Holschuh
<hmh@hmh.eng.br> wrote:
> On Thu, 04 Sep 2014, H. Peter Anvin wrote:
>> On 09/04/2014 01:11 PM, Henrique de Moraes Holschuh wrote:
>> > I am worried of uncharted territory, here.  I'd actually advocate for not
>> > enabling the upper four PAT entries on IA-32 at all, unless Windows 9X / XP
>> > is using them as well.  Is this a real concern, or am I being overly
>> > cautious?
>>
>> It is extremely unlikely that we'd have PAT issues in 32-bit mode and
>> not in 64-bit mode on the same CPU.
>
> Sure, but is it really a good idea to enable this on the *old* non-64-bit
> capable processors (note: I don't mean x86-64 processors operating in 32-bit
> mode) ?
>
>> As far as I know, the current blacklist rule is very conservative due to
>> lack of testing more than anything else.
>
> I was told that much in 2009 when I asked why cpuid 0x6d8 was blacklisted
> from using PAT :-)

At the very least, anyone who plugs an NV-DIMM into a 32-bit machine
is nuts, and not just because I'd be somewhat amazed if it even
physically fits into the slot. :)

--Andy

>
> --
>   "One disk to rule them all, One disk to find them. One disk to bring
>   them all and in the darkness grind them. In the Land of Redmond
>   where the shadows lie." -- The Silicon Valley Tarot
>   Henrique Holschuh



-- 
Andy Lutomirski
AMA Capital Management, LLC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

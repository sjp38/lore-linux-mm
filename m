Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7CBB16B0035
	for <linux-mm@kvack.org>; Tue, 13 May 2014 04:43:48 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d49so147599eek.1
        for <linux-mm@kvack.org>; Tue, 13 May 2014 01:43:47 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id v2si12535073eel.166.2014.05.13.01.43.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 May 2014 01:43:47 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC][PATCH 2/2] ARM: ioremap: Add IO mapping space reused support.
Date: Tue, 13 May 2014 10:43:06 +0200
Message-ID: <5026482.P9PDy29y2Y@wuerfel>
In-Reply-To: <CAHPCO9FRfR5p1N5v7mUk4hUYdPvqfLN6nW1LcnC83sU86ZFbZA@mail.gmail.com>
References: <1399861195-21087-1-git-send-email-superlibj8301@gmail.com> <5146762.jba3IJe7xt@wuerfel> <CAHPCO9FRfR5p1N5v7mUk4hUYdPvqfLN6nW1LcnC83sU86ZFbZA@mail.gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Lee <superlibj8301@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Richard Lee <superlibj@gmail.com>

On Tuesday 13 May 2014 09:45:08 Richard Lee wrote:
> > On Mon, May 12, 2014 at 3:51 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Monday 12 May 2014 10:19:55 Richard Lee wrote:
> >> For the IO mapping, for the same physical address space maybe
> >> mapped more than one time, for example, in some SoCs:
> >> 0x20000000 ~ 0x20001000: are global control IO physical map,
> >> and this range space will be used by many drivers.
> >> And then if each driver will do the same ioremap operation, we
> >> will waste to much malloc virtual spaces.
> >>
> >> This patch add IO mapping space reused support.
> >>
> >> Signed-off-by: Richard Lee <superlibj@gmail.com>
> >
> > What happens if the first driver then unmaps the area?
> >
> 
> If the first driver will unmap the area, it shouldn't do any thing
> except decreasing the 'used' counter.

Ah, for some reason I didn't see your first patch that introduces
that counter.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

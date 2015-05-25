Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9B24C6B0098
	for <linux-mm@kvack.org>; Mon, 25 May 2015 12:48:22 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so74074892pac.2
        for <linux-mm@kvack.org>; Mon, 25 May 2015 09:48:22 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ea16si16853313pad.208.2015.05.25.09.48.21
        for <linux-mm@kvack.org>;
        Mon, 25 May 2015 09:48:21 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
From: Catalin Marinas <catalin.marinas@foss.arm.com>
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH 2/2] arm64: Implement vmalloc based thread_info allocator
Date: Mon, 25 May 2015 19:47:15 +0300
Message-Id: <F68D2983-226C-4704-A1E0-E79C9425B822@foss.arm.com>
References: <1432483340-23157-1-git-send-email-jungseoklee85@gmail.com> <5992243.NYDGjLH37z@wuerfel> <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com>
In-Reply-To: <B873B881-4972-4524-B1D9-4BB05D7248A4@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jungseok Lee <jungseoklee85@gmail.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Catalin Marinas <catalin.marinas@arm.com>, "barami97@gmail.com" <barami97@gmail.com>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 25 May 2015, at 13:01, Jungseok Lee <jungseoklee85@gmail.com> wrote:

>> Could the stack size be reduced to 8KB perhaps?
>=20
> I guess probably not.
>=20
> A commit, 845ad05e, says that 8KB is not enough to cover SpecWeb benchmark=
.

We could go back to 8KB stacks if we implement support for separate IRQ=20
stack on arm64. It's not too complicated, we would have to use SP0 for (kern=
el) threads=20
and SP1 for IRQ handlers.

Catalin=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

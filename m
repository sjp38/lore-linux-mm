Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4541F6B04A8
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 19:37:56 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id z24so54860pgu.20
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 16:37:56 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g34sor647537pld.69.2018.01.03.16.37.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jan 2018 16:37:55 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: "bad pmd" errors + oops with KPTI on 4.14.11 after loading X.509 certs
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <20180104003303.GA1654@trogon.sfo.coreos.systems>
Date: Wed, 3 Jan 2018 16:37:53 -0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <DE0BC12C-4BA8-46AF-BD90-6904B9F87187@amacapital.net>
References: <CAD3VwcrHs8W_kMXKyDjKnjNDkkK57-0qFS5ATJYCphJHU0V3ow@mail.gmail.com> <20180103084600.GA31648@trogon.sfo.coreos.systems> <20180103092016.GA23772@kroah.com> <20180104003303.GA1654@trogon.sfo.coreos.systems>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Gilbert <benjamin.gilbert@coreos.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>



> On Jan 3, 2018, at 4:33 PM, Benjamin Gilbert <benjamin.gilbert@coreos.com>=
 wrote:
>=20
>> On Wed, Jan 03, 2018 at 10:20:16AM +0100, Greg Kroah-Hartman wrote:
>> Ick, not good, any chance you can test 4.15-rc6 to verify that the issue
>> is also there (or not)?
>=20
> I haven't been able to reproduce this on 4.15-rc6.

Ah.  Maybe try rebuilding a bad kernel with free_ldt_pgtables() modified to d=
o nothing, and the read /sys/kernel/debug/page_tables/current (or current_ke=
rnel, or whatever it's called).  The problem may be obvious.

>=20
> --Benjamin Gilbert

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

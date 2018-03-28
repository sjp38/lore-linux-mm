Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B94606B0011
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 14:48:26 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m16-v6so1022383lfc.0
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 11:48:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e19sor1124779ljj.82.2018.03.28.11.48.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 11:48:25 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <20180327221635.GA3790@thunk.org>
Date: Wed, 28 Mar 2018 21:48:22 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <B217D90A-6200-4257-804A-50D6C0308470@gmail.com>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
 <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
 <20180326084650.GC5652@dhcp22.suse.cz>
 <01A133F4-27DF-4AE2-80D6-B0368BF758CD@gmail.com>
 <20180327072432.GY5652@dhcp22.suse.cz>
 <0549F29C-12FC-4401-9E85-A430BC11DA78@gmail.com>
 <20180327221635.GA3790@thunk.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Theodore Y. Ts'o" <tytso@mit.edu>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, jejb@parisc-linux.org, Helge Deller <deller@gmx.de>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, Hugh Dickins <hughd@google.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, Andrew Morton <akpm@linux-foundation.org>, steve.capper@arm.com, punit.agrawal@arm.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, Kees Cook <keescook@chromium.org>, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

> On 28 Mar 2018, at 01:16, Theodore Y. Ts'o <tytso@mit.edu> wrote:
>=20
> On Tue, Mar 27, 2018 at 04:51:08PM +0300, Ilya Smith wrote:
>>> /dev/[u]random is not sufficient?
>>=20
>> Using /dev/[u]random makes 3 syscalls - open, read, close. This is a =
performance
>> issue.
>=20
> You may want to take a look at the getrandom(2) system call, which is
> the recommended way getting secure random numbers from the kernel.
>=20
>>> Well, I am pretty sure userspace can implement proper free ranges
>>> tracking=E2=80=A6
>>=20
>> I think we need to know what libc developers will say on implementing =
ASLR in=20
>> user-mode. I am pretty sure they will say =E2=80=98nether=E2=80=99 or =
=E2=80=98some-day=E2=80=99. And problem=20
>> of ASLR will stay forever.
>=20
> Why can't you send patches to the libc developers?
>=20
> Regards,
>=20
> 						- Ted

I still believe the issue is on kernel side, not in library.

Best regards,
Ilya

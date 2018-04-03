Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1207E6B0006
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 20:12:52 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f137so1894264wme.5
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 17:12:52 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c4sor374865ljd.99.2018.04.02.17.12.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 17:12:50 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F7B3B8BC5@ORSMSX110.amr.corp.intel.com>
Date: Tue, 3 Apr 2018 03:11:50 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <D9173B50-39D6-4EE5-AF8B-3EB50D0C9A3B@gmail.com>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
 <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
 <20180326084650.GC5652@dhcp22.suse.cz>
 <01A133F4-27DF-4AE2-80D6-B0368BF758CD@gmail.com>
 <20180327072432.GY5652@dhcp22.suse.cz>
 <0549F29C-12FC-4401-9E85-A430BC11DA78@gmail.com>
 <CAGXu5j+XXufprMaJ9GbHxD3mZ7iqUuu60-tTMC6wo2x1puYzMQ@mail.gmail.com>
 <20180327234904.GA27734@bombadil.infradead.org>
 <20180328000025.GM1436@brightrain.aerifal.cx>
 <3908561D78D1C84285E8C5FCA982C28F7B3B8BC5@ORSMSX110.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Rich Felker <dalias@libc.org>, Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Richard Henderson <rth@twiddle.net>, "ink@jurassic.park.msu.ru" <ink@jurassic.park.msu.ru>, "mattst88@gmail.com" <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, "Yu, Fenghua" <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, "nyc@holomorphy.com" <nyc@holomorphy.com>, Al Viro <viro@zeniv.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Deepa Dinamani <deepa.kernel@gmail.com>, Hugh Dickins <hughd@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Andrew Morton <akpm@linux-foundation.org>, Steve Capper <steve.capper@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nick Piggin <npiggin@gmail.com>, Bhupesh Sharma <bhsharma@redhat.com>, Rik van Riel <riel@redhat.com>, "nitin.m.gupta@oracle.com" <nitin.m.gupta@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "linux-alpha@vger.kernel.org" <linux-alpha@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-snps-arc@lists.infradead.org" <linux-snps-arc@lists.infradead.org>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, "linux-metag@vger.kernel.org" <linux-metag@vger.kernel.org>, Linux MIPS Mailing List <linux-mips@linux-mips.org>, linux-parisc <linux-parisc@vger.kernel.org>, PowerPC <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, linux-sh <linux-sh@vger.kernel.org>, sparclinux <sparclinux@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> On 29 Mar 2018, at 00:07, Luck, Tony <tony.luck@intel.com> wrote:
>=20
>> The default limit of only 65536 VMAs will also quickly come into play
>> if consecutive anon mmaps don't get merged. Of course this can be
>> raised, but it has significant resource and performance (fork) costs.
>=20
> Could the random mmap address chooser look for how many existing
> VMAs have space before/after and the right attributes to merge with =
the
> new one you want to create? If this is above some threshold (100?) =
then
> pick one of them randomly and allocate the new address so that it will
> merge from below/above with an existing one.
>=20
> That should still give you a very high degree of randomness, but =
prevent
> out of control numbers of VMAs from being created.

I think this wouldn=E2=80=99t work. For example these 100 allocation may =
happened on=20
process initialization. But when attacker come to the server all his=20
allocations would be made on the predictable offsets from each other. So =
in=20
result we did nothing just decrease performance of first 100 =
allocations. I=20
think I can make ioctl to turn off this randomization per process and it =
could=20
be used if needed. For example if application going to allocate big =
chunk or=20
make big memory pressure, etc.

Best regards,
Ilya

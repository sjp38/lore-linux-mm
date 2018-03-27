Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id B3A416B0006
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 18:17:20 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id i16-v6so204390ybk.21
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 15:17:20 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id b125si484925ywf.609.2018.03.27.15.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Mar 2018 15:17:19 -0700 (PDT)
Date: Tue, 27 Mar 2018 18:16:35 -0400
From: "Theodore Y. Ts'o" <tytso@mit.edu>
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
Message-ID: <20180327221635.GA3790@thunk.org>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180323124806.GA5624@bombadil.infradead.org>
 <651E0DB6-4507-4DA1-AD46-9C26ED9792A8@gmail.com>
 <20180326084650.GC5652@dhcp22.suse.cz>
 <01A133F4-27DF-4AE2-80D6-B0368BF758CD@gmail.com>
 <20180327072432.GY5652@dhcp22.suse.cz>
 <0549F29C-12FC-4401-9E85-A430BC11DA78@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0549F29C-12FC-4401-9E85-A430BC11DA78@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ilya Smith <blackzert@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, ralf@linux-mips.org, jejb@parisc-linux.org, Helge Deller <deller@gmx.de>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, dalias@libc.org, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, Hugh Dickins <hughd@google.com>, kstewart@linuxfoundation.org, pombredanne@nexb.com, Andrew Morton <akpm@linux-foundation.org>, steve.capper@arm.com, punit.agrawal@arm.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, Kees Cook <keescook@chromium.org>, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, ross.zwisler@linux.intel.com, Jerome Glisse <jglisse@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-alpha@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-snps-arc@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Linux-MM <linux-mm@kvack.org>

On Tue, Mar 27, 2018 at 04:51:08PM +0300, Ilya Smith wrote:
> > /dev/[u]random is not sufficient?
> 
> Using /dev/[u]random makes 3 syscalls - open, read, close. This is a performance
> issue.

You may want to take a look at the getrandom(2) system call, which is
the recommended way getting secure random numbers from the kernel.

> > Well, I am pretty sure userspace can implement proper free ranges
> > trackinga?|
> 
> I think we need to know what libc developers will say on implementing ASLR in 
> user-mode. I am pretty sure they will say a??nethera?? or a??some-daya??. And problem 
> of ASLR will stay forever.

Why can't you send patches to the libc developers?

Regards,

						- Ted

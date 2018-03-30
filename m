Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA9F6B0010
	for <linux-mm@kvack.org>; Fri, 30 Mar 2018 09:37:32 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m67so6018491qkl.10
        for <linux-mm@kvack.org>; Fri, 30 Mar 2018 06:37:32 -0700 (PDT)
Received: from brightrain.aerifal.cx (216-12-86-13.cv.mvl.ntelos.net. [216.12.86.13])
        by mx.google.com with ESMTP id 34si292571qks.5.2018.03.30.06.37.31
        for <linux-mm@kvack.org>;
        Fri, 30 Mar 2018 06:37:31 -0700 (PDT)
Date: Fri, 30 Mar 2018 09:33:48 -0400
From: Rich Felker <dalias@libc.org>
Subject: Re: [RFC PATCH v2 0/2] Randomization of address chosen by mmap.
Message-ID: <20180330133348.GR1436@brightrain.aerifal.cx>
References: <1521736598-12812-1-git-send-email-blackzert@gmail.com>
 <20180330075508.GA21798@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180330075508.GA21798@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Ilya Smith <blackzert@gmail.com>, rth@twiddle.net, ink@jurassic.park.msu.ru, mattst88@gmail.com, vgupta@synopsys.com, linux@armlinux.org.uk, tony.luck@intel.com, fenghua.yu@intel.com, jhogan@kernel.org, ralf@linux-mips.org, jejb@parisc-linux.org, deller@gmx.de, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, ysato@users.sourceforge.jp, davem@davemloft.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, nyc@holomorphy.com, viro@zeniv.linux.org.uk, arnd@arndb.de, gregkh@linuxfoundation.org, deepa.kernel@gmail.com, mhocko@suse.com, hughd@google.com, kstewart@linuxfoundation.org, pombredanne@nexb.com, akpm@linux-foundation.org, steve.capper@arm.com, punit.agrawal@arm.com, paul.burton@mips.com, aneesh.kumar@linux.vnet.ibm.com, npiggin@gmail.com, keescook@chromium.org, bhsharma@redhat.com, riel@redhat.com, nitin.m.gupta@oracle.com, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, jack@suse.cz, ross.zwisler@linux.intel.com, jglisse@redhat.com, willy@infradead.org, aarcange@redhat.com, oleg@redhat.com, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 30, 2018 at 09:55:08AM +0200, Pavel Machek wrote:
> Hi!
> 
> > Current implementation doesn't randomize address returned by mmap.
> > All the entropy ends with choosing mmap_base_addr at the process
> > creation. After that mmap build very predictable layout of address
> > space. It allows to bypass ASLR in many cases. This patch make
> > randomization of address on any mmap call.
> 
> How will this interact with people debugging their application, and
> getting different behaviours based on memory layout?
> 
> strace, strace again, get different results?

Normally gdb disables ASLR for the process when invoking a program to
debug. I don't see why that would be terribly useful with strace but
you can do the same if you want.

Rich

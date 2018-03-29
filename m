Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A18486B0008
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:42:12 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 31so2910663wrr.2
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:42:12 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id u18si1458907wmu.101.2018.03.29.07.42.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 07:42:11 -0700 (PDT)
Date: Thu, 29 Mar 2018 16:42:09 +0200
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: [PATCH 000/109] remove in-kernel calls to syscalls
Message-ID: <20180329144209.GA25559@isilmar-4.linta.de>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
 <20180329142027.GA24860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329142027.GA24860@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, hmclauchlan@fb.com, tautschn@amazon.co.uk, Amir Goldstein <amir73il@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Darren Hart <dvhart@infradead.org>, "David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Jaswinder Singh <jaswinder@infradead.org>, Jeff Dike <jdike@addtoit.com>, Jiri Slaby <jslaby@suse.com>, kexec@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, "Luis R . Rodriguez" <mcgrof@kernel.org>, netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, user-mode-linux-devel@lists.sourceforge.net, x86@kernel.org

On Thu, Mar 29, 2018 at 07:20:27AM -0700, Matthew Wilcox wrote:
> On Thu, Mar 29, 2018 at 01:22:37PM +0200, Dominik Brodowski wrote:
> > At least on 64-bit x86, it will likely be a hard requirement from v4.17
> > onwards to not call system call functions in the kernel: It is better to
> > use use a different calling convention for system calls there, where 
> > struct pt_regs is decoded on-the-fly in a syscall wrapper which then hands
> > processing over to the actual syscall function. This means that only those
> > parameters which are actually needed for a specific syscall are passed on
> > during syscall entry, instead of filling in six CPU registers with random
> > user space content all the time (which may cause serious trouble down the
> > call chain).[*]
> 
> How do we stop new ones from springing up?  Some kind of linker trick
> like was used to, er, "dissuade" people from using gets()?

Once the patches which modify the syscall calling convention are merged,
it won't compile on 64-bit x86, but bark loudly. That should frighten anyone.
Meow.

Thanks,
	Dominik

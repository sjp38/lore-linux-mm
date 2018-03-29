Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5C7976B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 10:21:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n15so4494892pff.14
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:21:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u7-v6si5964640plz.562.2018.03.29.07.21.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 29 Mar 2018 07:21:44 -0700 (PDT)
Date: Thu, 29 Mar 2018 07:20:27 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 000/109] remove in-kernel calls to syscalls
Message-ID: <20180329142027.GA24860@bombadil.infradead.org>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Cc: linux-kernel@vger.kernel.org, viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, hmclauchlan@fb.com, tautschn@amazon.co.uk, Amir Goldstein <amir73il@gmail.com>, Andi Kleen <ak@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Darren Hart <dvhart@infradead.org>, "David S . Miller" <davem@davemloft.net>, "Eric W . Biederman" <ebiederm@xmission.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Jaswinder Singh <jaswinder@infradead.org>, Jeff Dike <jdike@addtoit.com>, Jiri Slaby <jslaby@suse.com>, kexec@lists.infradead.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-s390@vger.kernel.org, "Luis R . Rodriguez" <mcgrof@kernel.org>, netdev@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, user-mode-linux-devel@lists.sourceforge.net, x86@kernel.org

On Thu, Mar 29, 2018 at 01:22:37PM +0200, Dominik Brodowski wrote:
> At least on 64-bit x86, it will likely be a hard requirement from v4.17
> onwards to not call system call functions in the kernel: It is better to
> use use a different calling convention for system calls there, where 
> struct pt_regs is decoded on-the-fly in a syscall wrapper which then hands
> processing over to the actual syscall function. This means that only those
> parameters which are actually needed for a specific syscall are passed on
> during syscall entry, instead of filling in six CPU registers with random
> user space content all the time (which may cause serious trouble down the
> call chain).[*]

How do we stop new ones from springing up?  Some kind of linker trick
like was used to, er, "dissuade" people from using gets()?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 634436B0253
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 05:10:17 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id r129so138521146wmr.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 02:10:17 -0800 (PST)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id hn6si7433918wjc.229.2016.01.27.02.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jan 2016 02:10:16 -0800 (PST)
Date: Wed, 27 Jan 2016 11:09:04 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: several messages
In-Reply-To: <20160125185706.GA28416@gmail.com>
Message-ID: <alpine.DEB.2.11.1601271108230.3886@nanos>
References: <cover.1453746505.git.luto@kernel.org> <20160125185706.GA28416@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Mon, 25 Jan 2016, Andy Lutomirski wrote:
> This is a straightforward speedup on Ivy Bridge and newer, IIRC.
> (I tested on Skylake.  INVPCID is not available on Sandy Bridge.
> I don't have Ivy Bridge, Haswell or Broadwell to test on, so I
> could be wrong as to when the feature was introduced.)

Haswell and Broadwell have it. No idea about ivy bridge.
 
Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

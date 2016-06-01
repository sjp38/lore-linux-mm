Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3416A6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 15:42:30 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id um11so18908623pab.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 12:42:30 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j2si17564604paw.80.2016.06.01.12.42.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 12:42:29 -0700 (PDT)
Date: Wed, 1 Jun 2016 12:42:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Message-Id: <20160601124227.e922af8299168c09308d5e1b@linux-foundation.org>
In-Reply-To: <20160531013145.612696c12f2ef744af739803@gmail.com>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
	<20160531013145.612696c12f2ef744af739803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: kernel-hardening@lists.openwall.com, pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

On Tue, 31 May 2016 01:31:45 +0200 Emese Revfy <re.emese@gmail.com> wrote:

> This plugin mitigates the problem of the kernel having too little entropy during
> and after boot for generating crypto keys.
> 
> It creates a local variable in every marked function. The value of this variable is
> modified by randomly chosen operations (add, xor and rol) and
> random values (gcc generates them at compile time and the stack pointer at runtime).
> It depends on the control flow (e.g., loops, conditions).
> 
> Before the function returns the plugin writes this local variable
> into the latent_entropy global variable. The value of this global variable is
> added to the kernel entropy pool in do_one_initcall() and _do_fork().

I don't think I'm really understanding.  Won't this produce the same
value on each and every boot?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

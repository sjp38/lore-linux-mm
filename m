Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB1A26B0005
	for <linux-mm@kvack.org>; Mon,  6 Jun 2016 09:38:05 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id yu3so33713480obb.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:38:05 -0700 (PDT)
Received: from mail-io0-x22c.google.com (mail-io0-x22c.google.com. [2607:f8b0:4001:c06::22c])
        by mx.google.com with ESMTPS id j19si19794353ioo.156.2016.06.06.06.38.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 06:38:05 -0700 (PDT)
Received: by mail-io0-x22c.google.com with SMTP id n127so16518769iof.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 06:38:05 -0700 (PDT)
Date: Mon, 6 Jun 2016 07:38:01 -0600
From: David Brown <david.brown@linaro.org>
Subject: Re: [kernel-hardening] Re: [PATCH v2 1/3] Add the latent_entropy gcc
 plugin
Message-ID: <20160606133801.GA6136@davidb.org>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
 <20160531013145.612696c12f2ef744af739803@gmail.com>
 <20160601124227.e922af8299168c09308d5e1b@linux-foundation.org>
 <20160603194252.91064b8e682ad988283fc569@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20160603194252.91064b8e682ad988283fc569@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Andrew Morton <akpm@linux-foundation.org>, pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

On Fri, Jun 03, 2016 at 07:42:52PM +0200, Emese Revfy wrote:
>On Wed, 1 Jun 2016 12:42:27 -0700
>Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> On Tue, 31 May 2016 01:31:45 +0200 Emese Revfy <re.emese@gmail.com> wrote:
>>
>> > This plugin mitigates the problem of the kernel having too little entropy during
>> > and after boot for generating crypto keys.
>> >
>> > It creates a local variable in every marked function. The value of this variable is
>> > modified by randomly chosen operations (add, xor and rol) and
>> > random values (gcc generates them at compile time and the stack pointer at runtime).
>> > It depends on the control flow (e.g., loops, conditions).
>> >
>> > Before the function returns the plugin writes this local variable
>> > into the latent_entropy global variable. The value of this global variable is
>> > added to the kernel entropy pool in do_one_initcall() and _do_fork().
>>
>> I don't think I'm really understanding.  Won't this produce the same
>> value on each and every boot?
>
>No, because of interrupts and intentional data races.

Wouldn't that result in the value having one of a small number of
values, then?  Even if it was just one of thousands or millions of
values, it would make the search space quite small.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

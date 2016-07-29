Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAD4E6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 13:50:53 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so114469231pad.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:50:53 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x4si19390801pfa.54.2016.07.29.10.50.52
        for <linux-mm@kvack.org>;
        Fri, 29 Jul 2016 10:50:52 -0700 (PDT)
Subject: Re: [PATCH 08/10] x86, pkeys: default to a restrictive init PKRU
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
 <20160729163021.F3C25D4A@viggo.jf.intel.com>
 <CALCETrWMg=+YSi7Az+gw9B59OoAEkOd=znpr7+++5=UUg6DThw@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <579B977B.7090609@intel.com>
Date: Fri, 29 Jul 2016 10:50:51 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrWMg=+YSi7Az+gw9B59OoAEkOd=znpr7+++5=UUg6DThw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>

On 07/29/2016 10:29 AM, Andy Lutomirski wrote:
>> > In the end, this ensures that threads which do not know how to
>> > manage their own pkey rights can not do damage to data which is
>> > pkey-protected.
> I think you missed the fpu__clear() caller in kernel/fpu/signal.c.
> 
> ISTM it might be more comprehensible to change fpu__clear in general
> and then special case things you want to behave differently.

The code actually already patched the generic fpu__clear():

	fpu__clear() ->
	copy_init_fpstate_to_fpregs() ->
	copy_init_pkru_to_fpregs()

So I think it hit the case you are talking about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

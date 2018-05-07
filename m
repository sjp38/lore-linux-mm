Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 985596B0269
	for <linux-mm@kvack.org>; Mon,  7 May 2018 05:47:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x79so10861058qkb.14
        for <linux-mm@kvack.org>; Mon, 07 May 2018 02:47:21 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id k84si19391663qke.291.2018.05.07.02.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 May 2018 02:47:20 -0700 (PDT)
Subject: Re: [PATCH] pkeys: Introduce PKEY_ALLOC_SIGNALINHERIT and change
 signal semantics
References: <20180502132751.05B9F401F3041@oldenburg.str.redhat.com>
 <248faadb-e484-806f-1485-c34a72a9ca0b@intel.com>
 <822a28c9-5405-68c2-11bf-0c282887466d@redhat.com>
 <20180502211254.GA5863@ram.oc3035372033.ibm.com>
 <CALCETrUfO=vXg5rT-n=y8pLktcq5+ORvgpsOXCHG4GaugB3k2A@mail.gmail.com>
 <20180502233848.GB5863@ram.oc3035372033.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <0bd6584e-f520-9e2d-8adb-f79d3d7e9340@redhat.com>
Date: Mon, 7 May 2018 11:47:17 +0200
MIME-Version: 1.0
In-Reply-To: <20180502233848.GB5863@ram.oc3035372033.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Linux-MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, linux-x86_64@vger.kernel.org, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, linuxppc-dev@lists.ozlabs.org

On 05/03/2018 01:38 AM, Ram Pai wrote:
> This is a new requirement that I was not aware off. Its not documented
> anywhere AFAICT.

Correct.  All inheritance behavior was deliberately left unspecified.

I'm surprised about the reluctance to fix the x86 behavior.  Are there 
any applications at all for the current semantics?

I guess I can implement this particular glibc hardening on POWER only 
for now.

Thanks,
Florian

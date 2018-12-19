Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id EAC028E0008
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 17:50:20 -0500 (EST)
Received: by mail-lj1-f200.google.com with SMTP id l12-v6so5897769ljb.11
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 14:50:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e11-v6sor12267462ljg.24.2018.12.19.14.50.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 14:50:18 -0800 (PST)
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
 <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
 <20181212104900.0af52c34@mschwideX1>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <cff2bb8d-bd61-c4a0-4e63-4de2133a7b38@gmail.com>
Date: Thu, 20 Dec 2018 00:50:12 +0200
MIME-Version: 1.0
In-Reply-To: <20181212104900.0af52c34@mschwideX1>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>, Andy Lutomirski <luto@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity <linux-integrity@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 12/12/2018 11:49, Martin Schwidefsky wrote:
> On Wed, 5 Dec 2018 15:13:56 -0800
> Andy Lutomirski <luto@kernel.org> wrote:

>> Hi s390 and powerpc people: it would be nice if this generic
>> implementation *worked* on your architectures and that it will allow
>> you to add some straightforward way to add a better arch-specific
>> implementation if you think that would be better.
> 
> As the code is right now I can guarantee that it will not work on s390.

OK, I have thrown the towel wrt developing at the same time for multiple 
architectures.

ATM I'm oriented toward getting support for one (x86_64), leaving the 
actual mechanism as architecture specific.

Then I can add another one or two and see what makes sense to refactor.
This approach should minimize the churning, overall.


--
igor

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 92BDA6B061B
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 12:26:04 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 94-v6so18054765pla.5
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 09:26:04 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i5-v6si3950201pgg.559.2018.11.08.09.26.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 09:26:03 -0800 (PST)
Date: Thu, 8 Nov 2018 12:25:57 -0500
From: Sasha Levin <sashal@kernel.org>
Subject: Re: stable request: mm: mlock: avoid increase mm->locked_vm on
 mlock() when already mlock2(,MLOCK_ONFAULT)
Message-ID: <20181108172557.GE8097@sasha-vm>
References: <CABdQkv_qGi7x4mQjH_mwGGnJs9F85CETOv9HLv=xvQVSPL_N3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CABdQkv_qGi7x4mQjH_mwGGnJs9F85CETOv9HLv=xvQVSPL_N3Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael David Tinoco <rafael.tinoco@linaro.org>, linux-mm@kvack.org
Cc: gregkh@linuxfoundation.org, stable@vger.kernel.org, kirill.shutemov@linux.intel.com, wei.guo.simon@gmail.com, akpm@linux-foundation.org

+ linux-mm@

This is actually upstream commit
b155b4fde5bdde9fed439cd1f5ea07173df2ed31.

On Thu, Nov 08, 2018 at 08:07:35AM -0200, Rafael David Tinoco wrote:
>Hello Greg,
>
>Could you please consider backporting to v4.4 the following commit:
>
>commit b5b5b6fe643391209b08528bef410e0cf299b826
>Author: Simon Guo <wei.guo.simon@gmail.com>
>Date:   Fri Oct 7 20:59:40 2016
>
>    mm: mlock: avoid increase mm->locked_vm on mlock() when already
>mlock2(,MLOCK_ONFAULT)
>
>It seems to be a trivial fix for:
>
>https://bugs.linaro.org/show_bug.cgi?id=4043
>(mlock203.c LTP test failing on v4.4)
>
>Thanks in advance,
>--
>Rafael D. Tinoco
>Linaro Kernel Validation Team

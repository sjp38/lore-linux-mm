Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 91EFE6B0007
	for <linux-mm@kvack.org>; Tue,  1 May 2018 17:46:07 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z10so11327445pfm.2
        for <linux-mm@kvack.org>; Tue, 01 May 2018 14:46:07 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j7si9246359pfh.3.2018.05.01.14.46.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 May 2018 14:46:06 -0700 (PDT)
Date: Tue, 1 May 2018 14:46:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] proc/kcore: Don't bounds check against address 0
Message-Id: <20180501144604.1cf872e7938bffc01a26349f@linux-foundation.org>
In-Reply-To: <20180501201143.15121-1-labbott@redhat.com>
References: <1039518799.26129578.1525185916272.JavaMail.zimbra@redhat.com>
	<20180501201143.15121-1-labbott@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Dave Anderson <anderson@redhat.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>

On Tue,  1 May 2018 13:11:43 -0700 Laura Abbott <labbott@redhat.com> wrote:

> The existing kcore code checks for bad addresses against
> __va(0) with the assumption that this is the lowest address
> on the system. This may not hold true on some systems (e.g.
> arm64) and produce overflows and crashes. Switch to using
> other functions to validate the address range.
> 
> Tested-by: Dave Anderson <anderson@redhat.com>
> Signed-off-by: Laura Abbott <labbott@redhat.com>
> ---
> I took your previous comments as a tested by, please let me know if that
> was wrong. This should probably just go through -mm. I don't think this
> is necessary for stable but I can request it later if necessary.

I'm surprised.  "overflows and crashes" sounds rather serious??

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A39386B0257
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 17:23:44 -0500 (EST)
Received: by wmec201 with SMTP id c201so233241386wme.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 14:23:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id pu5si7172675wjc.50.2015.12.08.14.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 14:23:43 -0800 (PST)
Date: Tue, 8 Dec 2015 14:23:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 01/13] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
Message-Id: <20151208142341.b91ab5728f244a68231e3b87@linux-foundation.org>
In-Reply-To: <20151208120743.GG19612@arm.com>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
	<1448886507-3216-2-git-send-email-ard.biesheuvel@linaro.org>
	<CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
	<20151208120743.GG19612@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Leif Lindholm <leif.lindholm@linaro.org>

On Tue, 8 Dec 2015 12:07:44 +0000 Will Deacon <will.deacon@arm.com> wrote:

> > I should note that this change should not affect any memblock users
> > that never set the MEMBLOCK_NOMAP flag, but please, if you see any
> > issues beyond 'this may conflict with other stuff we have queued for
> > 4.5', please do let me know.
> 
> Indeed, I can't see that this would cause any issues, but I would really
> like an Ack from one of the MM maintainers before taking this.
> 
> Please could somebody take a look?

It looks OK to me.  Please go ahead and merge it via an arm tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

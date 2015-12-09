Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id BE78C6B0255
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 06:29:30 -0500 (EST)
Received: by pfu207 with SMTP id 207so28864382pfu.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 03:29:30 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s12si12128089par.196.2015.12.09.03.29.29
        for <linux-mm@kvack.org>;
        Wed, 09 Dec 2015 03:29:29 -0800 (PST)
Date: Wed, 9 Dec 2015 11:29:27 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v4 01/13] mm/memblock: add MEMBLOCK_NOMAP attribute to
 memblock memory table
Message-ID: <20151209112926.GA9303@arm.com>
References: <1448886507-3216-1-git-send-email-ard.biesheuvel@linaro.org>
 <1448886507-3216-2-git-send-email-ard.biesheuvel@linaro.org>
 <CAKv+Gu9oboT_Lk8heJWRcM=oxRW=EWioVCvZLH7N0YCkfU5tJw@mail.gmail.com>
 <20151208120743.GG19612@arm.com>
 <20151208142341.b91ab5728f244a68231e3b87@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151208142341.b91ab5728f244a68231e3b87@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Alexander Kuleshov <kuleshovmail@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ryan Harkin <ryan.harkin@linaro.org>, Grant Likely <grant.likely@linaro.org>, Roy Franz <roy.franz@linaro.org>, Mark Salter <msalter@redhat.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, "linux-efi@vger.kernel.org" <linux-efi@vger.kernel.org>, Matt Fleming <matt@codeblueprint.co.uk>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Leif Lindholm <leif.lindholm@linaro.org>

On Tue, Dec 08, 2015 at 02:23:41PM -0800, Andrew Morton wrote:
> On Tue, 8 Dec 2015 12:07:44 +0000 Will Deacon <will.deacon@arm.com> wrote:
> 
> > > I should note that this change should not affect any memblock users
> > > that never set the MEMBLOCK_NOMAP flag, but please, if you see any
> > > issues beyond 'this may conflict with other stuff we have queued for
> > > 4.5', please do let me know.
> > 
> > Indeed, I can't see that this would cause any issues, but I would really
> > like an Ack from one of the MM maintainers before taking this.
> > 
> > Please could somebody take a look?
> 
> It looks OK to me.  Please go ahead and merge it via an arm tree.

Will do, thanks Andrew.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

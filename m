Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5516B0003
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 13:56:51 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b4so2073733pgs.5
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 10:56:51 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id v8-v6si327111plp.785.2018.02.08.10.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Feb 2018 10:56:50 -0800 (PST)
Date: Thu, 8 Feb 2018 10:56:48 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Message-ID: <20180208185648.GB9524@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
 <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
 <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+DvKQLHDR0s=6r4uiHL8kw2_PnfJcwYfPxgQOmuLbc=5k39+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Jann Horn <jannh@google.com>, linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 08, 2018 at 01:05:33PM -0500, Daniel Micay wrote:
> The standard map_max_count / pid_max are very low and there are many
> situations where either or both need to be raised.

[snip good reasons]

> I do think the default value in the documentation should be fixed but
> if there's a clear problem with raising these it really needs to be
> fixed. Google either of the sysctl names and look at all the people
> running into issues and needing to raise them. It's only going to
> become more common to raise these with people trying to use lots of
> fine-grained sandboxing. Process-per-request is back in style.

So we should make the count saturate instead, then?  That's going to
be interesting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

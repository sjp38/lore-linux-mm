Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A0ED6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 10:40:08 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id 199so29091810iou.0
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 07:40:08 -0800 (PST)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id p90si325641ioo.304.2018.02.05.07.40.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 07:40:07 -0800 (PST)
Date: Mon, 5 Feb 2018 09:40:04 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [kernel-hardening] [PATCH 4/6] Protectable Memory
In-Reply-To: <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
Message-ID: <alpine.DEB.2.20.1802050935300.10705@nuc-kabylake>
References: <20180124175631.22925-1-igor.stoppa@huawei.com> <20180124175631.22925-5-igor.stoppa@huawei.com> <CAG48ez0JRU8Nmn7jLBVoy6SMMrcj46R0_R30Lcyouc4R9igi-g@mail.gmail.com> <20180126053542.GA30189@bombadil.infradead.org> <alpine.DEB.2.20.1802021236510.31548@nuc-kabylake>
 <f2ddaed0-313e-8664-8a26-9d10b66ed0c5@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: Matthew Wilcox <willy@infradead.org>, Boris Lukashev <blukashev@sempervictus.com>, Jann Horn <jannh@google.com>, jglisse@redhat.com, Kees Cook <keescook@chromium.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Sat, 3 Feb 2018, Igor Stoppa wrote:

> > We could even do this in a more thorough way. Can we use a ring 1 / 2
> > distinction to create a hardened OS core that policies the rest of
> > the ever expanding kernel with all its modules and this and that feature?
>
> What would be the differentiating criteria? Furthermore, what are the
> chances
> of invalidating the entire concept, because there is already an
> hypervisor using
> the higher level features?
> That is what you are proposing, if I understand correctly.

Were there not 4 rings as well as methods by the processor vendors to
virtualize them as well?

> > I think that will long term be a better approach and allow more than the
> > current hardening approaches can get you. It seems that we are willing to
> > tolerate significant performance regressions now. So lets use the
> > protection mechanisms that the hardware offers.
>
> I would rather *not* propose significant performance regression :-P

But we already have implemented significant kernel hardening which causes
performance regressions. Using hardware capabilities allows the processor
vendor to further optimize these mechanisms whereas the software
preventative measures are eating up more and more performance as the pile
them on. Plus these are methods that can be worked around. Restrictions
implemented in a higher ring can be enforced and are much better than
just "hardening" (which is making life difficult for the hackers and
throwing away performannce for the average user).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

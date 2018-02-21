Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5D5E6B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 17:35:30 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m19so1272916pgv.5
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 14:35:30 -0800 (PST)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id o64si340665pfb.346.2018.02.21.14.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Feb 2018 14:35:29 -0800 (PST)
Date: Wed, 21 Feb 2018 15:35:27 -0700
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 1/6] genalloc: track beginning of allocations
Message-ID: <20180221153527.12e7d12c@lwn.net>
In-Reply-To: <CAGXu5j+zRQfxRXoSC5G8EjeSkPkpeMxfedJbHEgFyYcyXWmW9w@mail.gmail.com>
References: <20180212165301.17933-1-igor.stoppa@huawei.com>
	<20180212165301.17933-2-igor.stoppa@huawei.com>
	<CAGXu5jJWLdsBr-6mXiFQprT-=h2qhhXAWRLQ+EaKKiubKOQOfw@mail.gmail.com>
	<daaee36a-e6c7-8fbf-b758-ecee5106da9a@huawei.com>
	<CAGXu5j+zRQfxRXoSC5G8EjeSkPkpeMxfedJbHEgFyYcyXWmW9w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Igor Stoppa <igor.stoppa@huawei.com>, Matthew Wilcox <willy@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>

On Wed, 21 Feb 2018 14:29:06 -0800
Kees Cook <keescook@chromium.org> wrote:

> >> I wonder if this might be more readable by splitting the kernel-doc
> >> changes from the bitmap changes? I.e. fix all the kernel-doc in one
> >> patch, and in the following, make the bitmap changes. Maybe it's such
> >> a small part that it doesn't matter, though?  
> >
> > I had the same thought, but then I would have made most of the kerneldoc
> > changes to something that would be altered by the following patch,
> > because it would have made little sense to fix only those parts that
> > would have survived.
> >
> > If it is really a problem to keep them together, I could put these
> > changes in a following patch. Would that be ok?  
> 
> Hmmm... I think keeping it as-is would be better than a trailing
> docs-only patch. Maybe Jon has an opinion?

I would be inclined to agree.  Putting docs changes with the associated
code changes helps to document the patch itself, among other things.  I
wouldn't split them up.

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

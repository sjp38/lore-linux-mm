Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4F8596B0038
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 16:43:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so23457006pfp.5
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 13:43:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j126si3208290pfc.51.2017.03.16.13.43.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 13:43:22 -0700 (PDT)
Date: Thu, 16 Mar 2017 13:43:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [HMM 00/16] HMM (Heterogeneous Memory Management) v18
Message-Id: <20170316134321.c5cf727c21abf89b7e6708a2@linux-foundation.org>
In-Reply-To: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>

On Thu, 16 Mar 2017 12:05:19 -0400 J__r__me Glisse <jglisse@redhat.com> wrote:

> Cliff note:

"Cliff's notes" isn't appropriate for a large feature such as this. 
Where's the long-form description?  One which permits readers to fully
understand the requirements, design, alternative designs, the
implementation, the interface(s), etc?

Have you ever spoken about HMM at a conference?  If so, the supporting
presentation documents might help here.  That's the level of detail
which should be presented here.

> HMM offers 2 things (each standing on its own). First
> it allows to use device memory transparently inside any process
> without any modifications to process program code.

Well.  What is "device memory"?  That's very vague.  What are the
characteristics of this memory?  Why is it a requirement that
userspace code be unaltered?  What are the security implications - does
the process need particular permissions to access this memory?  What is
the proposed interface to set up this access?

> Second it allows to mirror process address space on a device.

Why?  Why is this a requirement, how will it be used, what are the
use cases, etc?

I spent a bit of time trying to locate a decent writeup of this feature
but wasn't able to locate one.  I'm not seeing a Documentation/ update
in this patchset.  Perhaps if you were to sit down and write a detailed
Documentation/vm/hmm.txt then that would be a good starting point.

This stuff is important - it's not really feasible to perform a decent
review of this proposal unless the reviewer has access to this
high-level conceptual stuff.

So I'll take a look at merging this code as-is for testing purposes but
I won't be attempting to review it at this stage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

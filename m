Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDDA6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 18:03:20 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id r19so147763iod.7
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 15:03:20 -0700 (PDT)
Received: from resqmta-ch2-10v.sys.comcast.net (resqmta-ch2-10v.sys.comcast.net. [2001:558:fe21:29:69:252:207:42])
        by mx.google.com with ESMTPS id d138-v6si1987169itb.85.2018.04.10.15.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 15:03:19 -0700 (PDT)
Date: Tue, 10 Apr 2018 17:03:17 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Remove use of page->counter
In-Reply-To: <20180410205757.GD21336@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804101702240.30842@nuc-kabylake>
References: <20180410195429.GB21336@bombadil.infradead.org> <alpine.DEB.2.20.1804101545350.30437@nuc-kabylake> <20180410205757.GD21336@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org

On Tue, 10 Apr 2018, Matthew Wilcox wrote:

> > Is this aligned on a doubleword boundary? Maybe move the refcount below
> > the flags field?
>
> You need freelist and _mapcount to be in the same dword.  There's no
> space to put them both in dword 0, so that's used for flags and mapping
> / s_mem.  Then freelist, mapcount and refcount are in dword 1 (on 64-bit),
> or freelist & mapcount are in dword 1 on 32-bit.  After that, 32 and 64-bit
> no longer line up on the same dword boundaries.

Well its no longer clear from the definitions that this must be the case.
Clarify that in the next version?

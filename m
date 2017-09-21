Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B2E56B02F3
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 21:04:14 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id d6so6975963itc.6
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 18:04:14 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x71sor266471ita.41.2017.09.20.18.04.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 18:04:13 -0700 (PDT)
Date: Wed, 20 Sep 2017 19:04:10 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 03/11] mm, x86: Add support for eXclusive Page Frame
 Ownership (XPFO)
Message-ID: <20170921010410.d4baj2crnzrlzvdj@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <9ca0ef74-b409-2eae-07f8-9fd7d83989a5@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9ca0ef74-b409-2eae-07f8-9fd7d83989a5@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On Wed, Sep 20, 2017 at 05:28:11PM -0700, Dave Hansen wrote:
> At a high level, does this approach keep an attacker from being able to
> determine the address of data in the linear map, or does it keep them
> from being able to *exploit* it?

It keeps them from exploiting it, by faulting when a physmap alias is
used.

> Can you have a ret2dir attack if the attacker doesn't know the
> address, for instance?

Yes, through a technique similar to heap spraying. The original paper
has a study of this, section 5.2 outlines the attack and 7.2 describes
their success rate:

http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

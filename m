Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id AFD936B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 15:23:54 -0400 (EDT)
Received: by obbgp5 with SMTP id gp5so45212231obb.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 12:23:54 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id n9si2371626oem.66.2015.07.08.12.23.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 12:23:53 -0700 (PDT)
Date: Wed, 8 Jul 2015 13:23:51 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH V3 3/5] mm: mlock: Introduce VM_LOCKONFAULT and add
 mlock flags to enable it
Message-ID: <20150708132351.61c13db6@lwn.net>
In-Reply-To: <1436288623-13007-4-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
	<1436288623-13007-4-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Tue,  7 Jul 2015 13:03:41 -0400
Eric B Munson <emunson@akamai.com> wrote:

> This patch introduces the ability to request that pages are not
> pre-faulted, but are placed on the unevictable LRU when they are finally
> faulted in.  This can be done area at a time via the
> mlock2(MLOCK_ONFAULT) or the mlockall(MCL_ONFAULT) system calls.  These
> calls can be undone via munlock2(MLOCK_ONFAULT) or
> munlockall2(MCL_ONFAULT).

Quick, possibly dumb question: I've been beating my head against these for
a little bit, and I can't figure out what's supposed to happen in this
case:

	mlock2(addr, len, MLOCK_ONFAULT);
	munlock2(addr, len, MLOCK_LOCKED);

It looks to me like it will clear VM_LOCKED without actually unlocking any
pages.  Is that the intended result?

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 169B06B02C3
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 23:22:43 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b9so88056600pfl.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 20:22:43 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h186si32574130pfc.35.2017.06.05.20.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jun 2017 20:22:42 -0700 (PDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC 08/11] x86/mm: Add nopcid to turn off PCID
References: <cover.1496701658.git.luto@kernel.org>
	<d4eafd524ee51d003d7f7302d5e4e44dc4919e08.1496701658.git.luto@kernel.org>
Date: Mon, 05 Jun 2017 20:22:41 -0700
In-Reply-To: <d4eafd524ee51d003d7f7302d5e4e44dc4919e08.1496701658.git.luto@kernel.org>
	(Andy Lutomirski's message of "Mon, 5 Jun 2017 15:36:32 -0700")
Message-ID: <87wp8pol4u.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Rik van Riel <riel@redhat.com>

Andy Lutomirski <luto@kernel.org> writes:

> The parameter is only present on x86_64 systems to save a few bytes,
> as PCID is always disabled on x86_32.

Seems redundant with clearcpuid.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBCB6B0055
	for <linux-mm@kvack.org>; Thu, 14 May 2009 15:32:46 -0400 (EDT)
Subject: Re: [PATCH] Physical Memory Management [0/1]
From: Andi Kleen <andi@firstfloor.org>
References: <op.utu26hq77p4s8u@amdc030>
	<20090513151142.5d166b92.akpm@linux-foundation.org>
	<op.utwwmpsf7p4s8u@amdc030> <1242300002.6642.1091.camel@laptop>
	<op.utw4fdhz7p4s8u@amdc030>
Date: Thu, 14 May 2009 21:33:11 +0200
In-Reply-To: <op.utw4fdhz7p4s8u@amdc030> (=?iso-8859-1?Q?Micha=E2?=
 Nazarewicz's message of "Thu, 14 May 2009 13:48:39 +0200")
Message-ID: <87skj7pjig.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?iso-8859-1?Q?Micha=E2?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Michaa Nazarewicz <m.nazarewicz@samsung.com> writes:
>
> The idea here is that there are n hardware accelerators, each
> can operate on 1MiB blocks (to simplify assume that's the case).

You could just define a hugepage size for that and use hugetlbfs
with a few changes to map in pages with multiple PTEs.
It supports boot time reservation and is a well established
interface.

On x86 that would give 2MB units, on other architectures whatever
you prefer.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

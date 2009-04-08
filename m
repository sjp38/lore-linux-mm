Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE725F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 01:49:52 -0400 (EDT)
Date: Tue, 7 Apr 2009 22:47:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-Id: <20090407224709.742376ff.akpm@linux-foundation.org>
In-Reply-To: <20090407509.382219156@firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue,  7 Apr 2009 17:09:56 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:

> Upcoming Intel CPUs have support for recovering from some memory errors. This
> requires the OS to declare a page "poisoned", kill the processes associated
> with it and avoid using it in the future. This patchkit implements
> the necessary infrastructure in the VM.

Seems that this feature is crying out for a testing framework (perhaps
it already has one?).  A simplistic approach would be

	echo some-pfn > /proc/bad-pfn-goes-here

A slightly more sophisticated version might do the deed from within a
timer interrupt, just to get a bit more coverage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

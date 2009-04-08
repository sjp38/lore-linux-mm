Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9485F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 01:19:21 -0400 (EDT)
Date: Tue, 7 Apr 2009 22:15:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [0/16] POISON: Intro
Message-Id: <20090407221542.91cd3c42.akpm@linux-foundation.org>
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

If the page is clean then we can just toss it and grab a new one from
backing store without killing anyone.

Does the patchset do that?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

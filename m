Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5595F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 01:18:08 -0400 (EDT)
Date: Tue, 7 Apr 2009 22:14:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] [2/16] POISON: Add page flag for poisoned pages
Message-Id: <20090407221421.890f27a6.akpm@linux-foundation.org>
In-Reply-To: <20090407150958.BA68F1D046D@basil.firstfloor.org>
References: <20090407509.382219156@firstfloor.org>
	<20090407150958.BA68F1D046D@basil.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Tue,  7 Apr 2009 17:09:58 +0200 (CEST) Andi Kleen <andi@firstfloor.org> wrote:

> Poisoned pages need special handling in the VM and shouldn't be touched 
> again. This requires a new page flag. Define it here.

I wish this patchset didn't change/abuse the well-understood meaning of
the word "poison".

> The page flags wars seem to be over, so it shouldn't be a problem
> to get a new one. I hope.

They are?  How did it all get addressed?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

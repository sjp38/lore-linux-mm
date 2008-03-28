Date: Thu, 27 Mar 2008 21:16:32 -0700 (PDT)
Message-Id: <20080327.211632.02770342.davem@davemloft.net>
Subject: Re: [patch 1/2]: x86: implement pte_special
From: David Miller <davem@davemloft.net>
In-Reply-To: <20080328041519.GF8083@wotan.suse.de>
References: <20080328040442.GE8083@wotan.suse.de>
	<20080327.210910.101408473.davem@davemloft.net>
	<20080328041519.GF8083@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Nick Piggin <npiggin@suse.de>
Date: Fri, 28 Mar 2008 05:15:20 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, shaggy@austin.ibm.com, axboe@oracle.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

> The other thing is that the "how do I know if I can refcount the page
> behind this (mm,vaddr,pte) tuple" can be quite arch specific as well.
> And it is also non-trivial to do because that information can be dynamic
> depending on what driver mapped in that given tuple.

Those are good points.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

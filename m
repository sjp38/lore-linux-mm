Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2788D6B0169
	for <linux-mm@kvack.org>; Fri, 29 Jul 2011 19:18:40 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
	<alpine.DEB.2.00.1107291002570.16178@router.home>
Date: Fri, 29 Jul 2011 16:18:37 -0700
In-Reply-To: <alpine.DEB.2.00.1107291002570.16178@router.home> (Christoph
	Lameter's message of "Fri, 29 Jul 2011 10:04:36 -0500 (CDT)")
Message-ID: <m2pqksznea.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, torvalds@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Christoph Lameter <cl@linux.com> writes:

> On Fri, 29 Jul 2011, Pekka Enberg wrote:
>
>> We haven't come up with a solution to keep struct page size the same but I
>> think it's a reasonable trade-off.
>
> The change requires the page struct to be aligned to a double word
> boundary. 

Why is that?

> There is actually no variable added to the page struct. Its just
> the alignment requirement that causes padding to be added after each page
> struct.

These days with everyone using cgroups (and likely mcgroups too) 
you could probably put the cgroups page pointer back there. It's
currently external.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

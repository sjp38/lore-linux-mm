Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4CDB36B021D
	for <linux-mm@kvack.org>; Thu, 29 Apr 2010 11:40:36 -0400 (EDT)
Message-ID: <4BD9A84C.3050709@redhat.com>
Date: Thu, 29 Apr 2010 11:39:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH -v3] take all anon_vma locks in anon_vma_lock
References: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>	 <20100428153525.GR510@random.random>	 <20100428155558.GI15815@csn.ul.ie>	 <20100428162305.GX510@random.random>	 <20100428134719.32e8011b@annuminas.surriel.com>	 <20100428142510.09984e15@annuminas.surriel.com>	 <20100428161711.5a815fa8@annuminas.surriel.com>	 <20100428165734.6541bab3@annuminas.surriel.com>	 <y2s28c262361004281728we31e3b9fsd2427aacdc76a9e7@mail.gmail.com>	 <4BD8EA85.2000209@redhat.com> <z2g28c262361004281955h29bc20edndb8da9c7cb5ff1db@mail.gmail.com>
In-Reply-To: <z2g28c262361004281955h29bc20edndb8da9c7cb5ff1db@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 04/28/2010 10:55 PM, Minchan Kim wrote:

> When you tried anon_vma_chain patches as I pointed out, what I have a
> concern is parent's vma not child's one.
> The vma of parent still has N anon_vma.

No, it is the other way around.

The anon_vma of the parent is also present in all of the
children, so the parent anon_vma is attached to N vmas.

However, the parent vma only has 1 anon_vma attached to
it, and each of the children will have 2 anon_vmas.

That is what should keep any locking overhead with this
patch minimal.

Yes, a deep fork bomb can slow itself down.  Too bad,
don't do that :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

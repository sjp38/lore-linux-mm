Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD168D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:24:43 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:24:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]mmap: add alignment for some variables
Message-Id: <20110329152434.d662706f.akpm@linux-foundation.org>
In-Reply-To: <1301360054.3981.31.camel@sli10-conroe>
References: <1301277536.3981.27.camel@sli10-conroe>
	<m2oc4v18x8.fsf@firstfloor.org>
	<1301360054.3981.31.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, 29 Mar 2011 08:54:14 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> -struct percpu_counter vm_committed_as;
> +struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;

Why ____cacheline_internodealigned_in_smp?  That's pretty aggressive.

afacit the main benefit from this will occur if the read-only
vm_committed_as.counters lands in the same cacheline as some
write-frequently storage.

But that's a complete mad guess and I'd prefer not to have to guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

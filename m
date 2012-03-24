Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5F5FF6B0044
	for <linux-mm@kvack.org>; Sat, 24 Mar 2012 19:50:25 -0400 (EDT)
Message-ID: <1332633000.2882.15.camel@pasglop>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 25 Mar 2012 10:50:00 +1100
In-Reply-To: <4F6DDE56.3090401@openvz.org>
References: <20120321065140.13852.52315.stgit@zurg>
	 <20120321100602.GA5522@barrios> <4F69D496.2040509@openvz.org>
	 <20120322053958.GA5278@barrios> <1332397358.2982.82.camel@pasglop>
	 <4F6DDE56.3090401@openvz.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

On Sat, 2012-03-24 at 18:46 +0400, Konstantin Khlebnikov wrote:
> Obviously we can combine VM_PFN_AT_MMAP, VM_SAO, VM_GROWSUP and
> VM_MAPPED_COPY into one.

VM_PFN_AT_MMAP isn't arch specific afaik...

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

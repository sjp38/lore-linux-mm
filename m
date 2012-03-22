Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id B06B56B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 02:23:01 -0400 (EDT)
Message-ID: <1332397358.2982.82.camel@pasglop>
Subject: Re: [PATCH 00/16] mm: prepare for converting vm->vm_flags to 64-bit
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Thu, 22 Mar 2012 17:22:38 +1100
In-Reply-To: <20120322053958.GA5278@barrios>
References: <20120321065140.13852.52315.stgit@zurg>
	 <20120321100602.GA5522@barrios> <4F69D496.2040509@openvz.org>
	 <20120322053958.GA5278@barrios>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>

On Thu, 2012-03-22 at 14:39 +0900, Minchan Kim wrote:
> I think we can also unify VM_MAPPED_COPY(nommu) and VM_SAO(powerpc)
> with one VM_ARCH_1
> Okay. After this series is merged, let's try to remove flags we can
> do. Then, other guys
> might suggest another ideas.

Agreed. I would like more VM_ARCH while at it :-)

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

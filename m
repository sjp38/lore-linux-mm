Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 88F266B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 03:43:27 -0500 (EST)
Date: Fri, 11 Nov 2011 08:42:51 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: mm: convert vma->vm_flags to 64bit
Message-ID: <20111111084251.GZ12913@n2100.arm.linux.org.uk>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com> <CAPQyPG7RrpV8DBV_Qcgr2at_r25_ngjy_84J2FqzRPGfA3PGDA@mail.gmail.com> <4EBC085D.3060107@jp.fujitsu.com> <1320959579.21206.24.camel@pasglop> <4EBC46FD.5010109@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4EBC46FD.5010109@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: benh@kernel.crashing.org, nai.xia@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, dave@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, lethal@linux-sh.org

On Thu, Nov 10, 2011 at 04:49:49PM -0500, KOSAKI Motohiro wrote:
> Maybe we need to ban useless arch specific flags at first.

Maybe a separate vma->vm_arch_flags for them if arches really want this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

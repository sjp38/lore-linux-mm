Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CF0685F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 04:31:38 -0400 (EDT)
Date: Wed, 15 Apr 2009 09:33:17 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: meminfo Committed_AS underflows
Message-ID: <20090415093317.4f937809@lxorguk.ukuu.org.uk>
In-Reply-To: <1239737619.32604.118.camel@nimitz>
References: <1239737619.32604.118.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Eric B Munson <ebmunson@us.ibm.com>, Mel Gorman <mel@linux.vnet.ibm.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> The 1023 cpus won't ever hit the ACCT_THRESHOLD.  The 1 CPU that did
> will decrement the global 'vm_committed_space'  by ~128 GB.  Underflow.
> Yay.  This happens on a much smaller scale now.
> 
> Should we be protecting meminfo so that it spits slightly more sane
> numbers out to the user?

Yes. It used to be accurate but the changes were put in as the memory
accounting value was actually starting to show up in profiles as it
bounced around the CPUs - perhaps the constraint should instead be a
worst case error as percentage of total system memory ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

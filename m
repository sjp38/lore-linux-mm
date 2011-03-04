Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A01228D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 06:58:09 -0500 (EST)
Date: Fri, 4 Mar 2011 11:58:05 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
Message-ID: <20110304115805.2e7d6917@lxorguk.ukuu.org.uk>
In-Reply-To: <2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
References: <1299174652.2071.12.camel@dan>
	<1299185882.3062.233.camel@calx>
	<1299186986.2071.90.camel@dan>
	<1299188667.3062.259.camel@calx>
	<1299191400.2071.203.camel@dan>
	<2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Tso <tytso@MIT.EDU>
Cc: Dan Rosenberg <drosenberg@vsecurity.com>, Matt Mackall <mpm@selenic.com>, cl@linux-foundation.org, penberg@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Being able to monitor /proc/slabinfo is incredibly useful for finding various
> kernel problems.  We can see if some part of the kernel is out of balance,

Making it 0400 doesn't stop that.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

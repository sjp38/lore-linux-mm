Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7D4538D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 13:30:00 -0500 (EST)
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Dan Rosenberg <drosenberg@vsecurity.com>
In-Reply-To: <1299176266.8493.2369.camel@nimitz>
References: <1299174652.2071.12.camel@dan>
	 <1299176266.8493.2369.camel@nimitz>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Mar 2011 13:29:55 -0500
Message-ID: <1299176995.2071.15.camel@dan>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org


> 
> Please don't.  In reality, it'll just mean that more data collection
> things will have to get done as root, and I'll wear my keyboard out more
> often sudo'ing.
> 
> If you really want this on particularly pedantic systems, why not chmod?
> 

I believe the vast majority of users do not need the ability to read
this file from an unprivileged login.  We should strive for security by
default.  As you said, you can simply chmod this file to regain the
access permissions you require for your less common use case.

> -- Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

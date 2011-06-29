Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 430A46B00EE
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 13:59:21 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5THbRRb029103
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 13:37:27 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5THxHuc1503444
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 13:59:17 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5TDx4kh025553
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 10:59:05 -0300
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110629174220.GA9152@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	 <20110629130038.GA7909@in.ibm.com> <1309367184.11430.594.camel@nimitz>
	 <20110629174220.GA9152@in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 29 Jun 2011 10:59:02 -0700
Message-ID: <1309370342.11430.604.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ankita Garg <ankita@in.ibm.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

On Wed, 2011-06-29 at 23:12 +0530, Ankita Garg wrote:
> 	4. The kernel must have a mechanism to maintain utilization
> 	   statistics pertaining to a piece of hardware, so that it can
> 	   trigger the hardware to power it off

Having statistics like this would certainly be nice, but how important
_is_ it?  Is it really a show-stopper?  There's some stuff today, like
the NPT/EPT support in KVM where we don't even have visibility in to
when a given page is referenced.

It's also going to be a pain to track kernel references.  On x86, our
kernel linear mapping uses 1GB pages when it can, and those are greater
than the 512MB granularity that we've been talking about here.  It's
even larger on powerpc.  I'm also pretty sure we don't even _look_ at
the referenced bits in the kernel page tables.  We'll definitely need
some infrastructure to do that.

> 	5. Being able to group these pieces of hardware for purpose of
> 	   higher savings. 

Do you really mean group, or do you mean "turn as many off as possible"?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

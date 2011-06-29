Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 497696B00E7
	for <linux-mm@kvack.org>; Wed, 29 Jun 2011 16:12:25 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory Power Management
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
	<20110629130038.GA7909@in.ibm.com> <1309367184.11430.594.camel@nimitz>
	<20110629174220.GA9152@in.ibm.com> <1309370342.11430.604.camel@nimitz>
Date: Wed, 29 Jun 2011 13:11:00 -0700
In-Reply-To: <1309370342.11430.604.camel@nimitz> (Dave Hansen's message of
	"Wed, 29 Jun 2011 10:59:02 -0700")
Message-ID: <m2y60k1jqj.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ankita Garg <ankita@in.ibm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Matthew Garrett <mjg59@srcf.ucam.org>, Arjan van de Ven <arjan@infradead.org>

Dave Hansen <dave@linux.vnet.ibm.com> writes:
>
> It's also going to be a pain to track kernel references.  On x86, our

Even if you tracked them what would you do with them?

It's quite hard to stop using arbitary kernel memory (see all the dancing
memory-failure does) 

You need to track the direct accesses to user data which happens
to be accessed through the direct mapping.

Also it will be always unreliable because this all won't track DMA.
For that you would also need to track in the dma_* infrastructure,
which will likely get seriously expensive.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

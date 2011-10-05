Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 25A739400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 12:27:52 -0400 (EDT)
Received: by wyf22 with SMTP id 22so2522523wyf.14
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 09:27:49 -0700 (PDT)
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <1317828155.7842.73.camel@nimitz>
References: <20111001000856.DD623081@kernel>
	 <20111001000900.BD9248B8@kernel>
	 <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com>
	 <1317798564.3099.12.camel@edumazet-laptop>
	 <1317828155.7842.73.camel@nimitz>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 05 Oct 2011 18:28:03 +0200
Message-ID: <1317832083.2473.58.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

Le mercredi 05 octobre 2011 A  08:22 -0700, Dave Hansen a A(C)crit :
> On Wed, 2011-10-05 at 09:09 +0200, Eric Dumazet wrote:
> > By the way, "pagesize=4KiB" are just noise if you ask me, thats the
> > default PAGE_SIZE. This also breaks old scripts :)
> 
> How does it break old scripts?
> 

Old scripts just parse numa_maps, and on typical machines where
hugepages are not used, they dont have to care about page size.
They assume pages are 4KB.

Adding a new word (pagesize=...) might break them, but personally I dont
care.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

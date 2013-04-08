Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id CD98F6B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 19:10:20 -0400 (EDT)
Received: by mail-qa0-f48.google.com with SMTP id hu16so1463974qab.0
        for <linux-mm@kvack.org>; Mon, 08 Apr 2013 16:10:19 -0700 (PDT)
Message-ID: <51634E58.4080104@gmail.com>
Date: Mon, 08 Apr 2013 19:10:16 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] mm: Another attempt to monitor task's memory
 changes
References: <515F0484.1010703@parallels.com>
In-Reply-To: <515F0484.1010703@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Glauber Costa <glommer@parallels.com>, Matthew Wilcox <willy@linux.intel.com>, kosaki.motohiro@gmail.com

> This approach works on any task via it's proc, and can be used on different
> tasks in parallel.
> 
> Also, Andrew was asking for some performance numbers related to the change.
> Now I can say, that as long as soft dirty bits are not cleared, no performance
> penalty occur, since the soft dirty bit and the regular dirty bit are set at 
> the same time within the same instruction. When soft dirty is cleared via 
> clear_refs, the task in question might slow down, but it will depend on how
> actively it uses the memory.
> 
> 
> What do you think, does it make sense to develop this approach further?

When touching mmaped page, cpu turns on dirty bit but doesn't turn on soft dirty.
So, I'm not convinced how to use this flag. Please show us your userland algorithm
how to detect diff.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5966B005D
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 15:24:35 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p95JORm8025890
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 12:24:28 -0700
Received: from vwe42 (vwe42.prod.google.com [10.241.18.42])
	by wpaz24.hot.corp.google.com with ESMTP id p95JOQBL013679
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 5 Oct 2011 12:24:26 -0700
Received: by vwe42 with SMTP id 42so2307187vwe.34
        for <linux-mm@kvack.org>; Wed, 05 Oct 2011 12:24:26 -0700 (PDT)
Date: Wed, 5 Oct 2011 12:24:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFCv3][PATCH 4/4] show page size in /proc/$pid/numa_maps
In-Reply-To: <1317832083.2473.58.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1110051219370.23587@chino.kir.corp.google.com>
References: <20111001000856.DD623081@kernel> <20111001000900.BD9248B8@kernel> <alpine.DEB.2.00.1110042344250.16359@chino.kir.corp.google.com> <1317798564.3099.12.camel@edumazet-laptop> <1317828155.7842.73.camel@nimitz>
 <1317832083.2473.58.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, James.Bottomley@hansenpartnership.com, hpa@zytor.com

On Wed, 5 Oct 2011, Eric Dumazet wrote:

> > How does it break old scripts?
> > 
> 
> Old scripts just parse numa_maps, and on typical machines where
> hugepages are not used, they dont have to care about page size.
> They assume pages are 4KB.
> 
> Adding a new word (pagesize=...) might break them, but personally I dont
> care.
> 

If your script is only parsing numa_maps, then Dave's effort is actually 
allowing them to be fixed rather than breaking them.  We could silently 
continue to export the page counts without specifying the size (hugetlb 
pages are counted in their true hugepage size, THP pages are counted in 
PAGE_SIZE units), but then a script would always be broken unless they use 
smaps as well.  Dave's addition of pagesize allows numa_maps to stand on 
its own and actually be useful when hugepages are used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

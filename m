Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 280EF900163
	for <linux-mm@kvack.org>; Tue,  2 Aug 2011 00:05:13 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p7245Apq022007
	for <linux-mm@kvack.org>; Mon, 1 Aug 2011 21:05:10 -0700
Received: from gxk27 (gxk27.prod.google.com [10.202.11.27])
	by wpaz1.hot.corp.google.com with ESMTP id p72457LW004199
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 1 Aug 2011 21:05:09 -0700
Received: by gxk27 with SMTP id 27so4316900gxk.29
        for <linux-mm@kvack.org>; Mon, 01 Aug 2011 21:05:07 -0700 (PDT)
Date: Mon, 1 Aug 2011 21:05:05 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1108012101310.6871@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com> <1312145146.24862.97.camel@jaguar>
 <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com> <CAOJsxLHB9jPNyU2qztbEHG4AZWjauCLkwUVYr--8PuBBg1=MCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 1 Aug 2011, Pekka Enberg wrote:

> Btw, I haven't measured this recently but in my testing, SLAB has
> pretty much always used more memory than SLUB. So 'throwing more
> memory at the problem' is definitely a reasonable approach for SLUB.
> 

Yes, slub _did_ use more memory than slab until the alignment of 
struct page.  That cost an additional 128MB on each of these 64GB 
machines, while the total slab usage on the client machine systemwide is 
~75MB while running netperf TCP_RR with 160 threads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

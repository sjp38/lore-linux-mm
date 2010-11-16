Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B1D928D0080
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 17:11:36 -0500 (EST)
Date: Tue, 16 Nov 2010 14:11:30 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-Id: <20101116141130.b20a8a8d.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap>
	<20101111120643.22dcda5b.akpm@linux-foundation.org>
	<1289512924.428.112.camel@oralap>
	<20101111142511.c98c3808.akpm@linux-foundation.org>
	<1289840500.13446.65.camel@oralap>
	<alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Nov 2010 13:28:54 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

>  - avoid doing anything other than GFP_KERNEL allocations for __vmalloc():
>    the only current users are gfs2, ntfs, and ceph (the page allocator
>    __vmalloc() can be discounted since it's done at boot and GFP_ATOMIC
>    here has almost no chance of failing since the size is determined based 
>    on what is available).

^^ this

Using vmalloc anywhere is lame.

Using anything weaker than GFP_KERNEL is lame.

Stomping out vmalloc callsites and stomping out non-GFP_KERNEL callers
will result in a better kernel *regardless* of this bug.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

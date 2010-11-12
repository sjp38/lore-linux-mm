Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 550F78D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 10:13:45 -0500 (EST)
Date: Fri, 12 Nov 2010 09:13:40 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH/RFC] MM slub: add a sysfs entry to show the calculated
 number of fallback slabs
In-Reply-To: <1289561309.1972.30.camel@castor.rsk>
Message-ID: <alpine.DEB.2.00.1011120911310.11746@router.home>
References: <1289561309.1972.30.camel@castor.rsk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Nov 2010, Richard Kennedy wrote:

> On my desktop workloads (kernel compile etc) I'm seeing surprisingly
> little slab fragmentation. Do you have any suggestions for test cases
> that will fragment the memory?

Do a massive scan through huge amounts of files that triggers inode and
dentry reclaim?

> + * Note that this can give the wrong answer if the user has changed the
> + * order of this slab via sysfs.

Not good. Maybe have an additional counter in kmem_cache_node instead?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

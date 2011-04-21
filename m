Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id ABB528D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 09:33:45 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1440350fxm.14
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 06:33:42 -0700 (PDT)
Date: Thu, 21 Apr 2011 15:32:48 +0200
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
Message-ID: <20110421133248.GD31724@htj.dyndns.org>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com>
 <1303267733.11237.42.camel@mulgrave.site>
 <20110420115804.461E.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1104200847240.8634@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1104200847240.8634@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

Hey,

On Wed, Apr 20, 2011 at 08:50:15AM -0500, Christoph Lameter wrote:
> Tejon was working on getting rid of DISCONTIG. SPARSEMEM is the favored
> alternative today. So we could potentially change the arches to use SPARSE
> configs in the !NUMA case.

Well, the thing is that sparsemem w/ vmemmap is definitely better than
discontigmem on x86-64; however, on x86-32, vmemmap can't be used due
to address space shortage and there are some minor disadvantages to
sparsemem compared to discontigmem.

IIRC, the biggest was losing a bit of granuality in memsections and
possibly wasting slightly more memory on the page array.  Both didn't
seem critical to me but given that the actual amount of code needed
for discontigmem in arch code was fairly small (although the amount of
added complexity for auditing/testing can be much higher) I didn't
feel sure about dropping discontigmem and thus the patchset to drop
discontigmem was posted as RFC, to which nobody commented.

  http://thread.gmane.org/gmane.linux.kernel/1121321

What do you guys think?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

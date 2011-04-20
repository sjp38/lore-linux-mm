Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 46F358D0040
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 07:20:26 -0400 (EDT)
Date: Wed, 20 Apr 2011 05:20:20 -0600
From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
	expand_upwards
Message-ID: <20110420112020.GA31296@parisc-linux.org>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com> <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Wed, Apr 20, 2011 at 10:34:23AM +0300, Pekka Enberg wrote:
> That part makes me think the best option is to make parisc do
> CONFIG_NUMA as well regardless of the historical intent was.

But it's not just parisc.  It's six other architectures as well, some
of which aren't even SMP.  Does !SMP && NUMA make any kind of sense?

I think really, this is just a giant horrible misunderstanding on the part
of the MM people.  There's no reason why an ARM chip with 16MB of memory
at 0 and 16MB of memory at 1GB should be saddled with all the NUMA gunk.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

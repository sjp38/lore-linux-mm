Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C74818D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 10:07:56 -0400 (EDT)
Date: Wed, 20 Apr 2011 09:07:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1104200906170.8634@router.home>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com> <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com> <20110420161615.462D.A69D9226@jp.fujitsu.com> <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>

On Wed, 20 Apr 2011, Pekka Enberg wrote:

> That part makes me think the best option is to make parisc do
> CONFIG_NUMA as well regardless of the historical intent was.

Another possilibity is to use SPARSEMEM instead? We can do the same for
the other arches that we have done to x86.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

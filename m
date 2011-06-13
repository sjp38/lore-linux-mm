Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 4BF8D6B0012
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 17:00:39 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p5DL0ZAY029107
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:00:35 -0700
Received: from yxl31 (yxl31.prod.google.com [10.190.3.223])
	by hpaq7.eem.corp.google.com with ESMTP id p5DKxOk8004476
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:00:34 -0700
Received: by yxl31 with SMTP id 31so240038yxl.27
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 14:00:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTi=RYq0Dd210VC+NeTXWWuFbz7cxeg@mail.gmail.com>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
	<alpine.DEB.2.00.1106131258300.3108@router.home>
	<1307990048.11288.3.camel@jaguar>
	<alpine.DEB.2.00.1106131428560.5601@router.home>
	<BANLkTi=RYq0Dd210VC+NeTXWWuFbz7cxeg@mail.gmail.com>
Date: Mon, 13 Jun 2011 14:00:31 -0700
Message-ID: <BANLkTik-KGtuoVFKvy_rk7voBRAxSsR9FRg0fhb0k3NCSg-fWQ@mail.gmail.com>
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
From: Hugh Dickins <hughd@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Jun 13, 2011 at 1:34 PM, Pekka Enberg <penberg@kernel.org> wrote:
> On Mon, Jun 13, 2011 at 10:29 PM, Christoph Lameter <cl@linux.com> wrote:
>> On Mon, 13 Jun 2011, Pekka Enberg wrote:
>>
>>> > Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
>>> > alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
>>> > was not applied? Pekka?
>>>
>>> This patch?
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=d4d84fef6d0366b585b7de13527a0faeca84d9ce
>>>
>>> It's queued and will be sent to Linus soon.
>>
>> Ok it will also fix Hugh's problem then.
>
> It's in Linus' tree now. Hugh, can you please confirm it fixes your machine too?

I expect it to, thanks: I'll confirm tonight.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

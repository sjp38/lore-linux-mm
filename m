Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6430B6B0012
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 16:34:24 -0400 (EDT)
Received: by vws4 with SMTP id 4so5515389vws.14
        for <linux-mm@kvack.org>; Mon, 13 Jun 2011 13:34:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1106131428560.5601@router.home>
References: <alpine.LSU.2.00.1106121842250.31463@sister.anvils>
	<alpine.DEB.2.00.1106131258300.3108@router.home>
	<1307990048.11288.3.camel@jaguar>
	<alpine.DEB.2.00.1106131428560.5601@router.home>
Date: Mon, 13 Jun 2011 23:34:22 +0300
Message-ID: <BANLkTi=RYq0Dd210VC+NeTXWWuFbz7cxeg@mail.gmail.com>
Subject: Re: [PATCH] slub: fix kernel BUG at mm/slub.c:1950!
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

On Mon, Jun 13, 2011 at 10:29 PM, Christoph Lameter <cl@linux.com> wrote:
> On Mon, 13 Jun 2011, Pekka Enberg wrote:
>
>> > Hmmm.. The allocpercpu in alloc_kmem_cache_cpus should take care of the
>> > alignment. Uhh.. I see that a patch that removes the #ifdef CMPXCHG_LOCAL
>> > was not applied? Pekka?
>>
>> This patch?
>>
>> http://git.kernel.org/?p=linux/kernel/git/penberg/slab-2.6.git;a=commitdiff;h=d4d84fef6d0366b585b7de13527a0faeca84d9ce
>>
>> It's queued and will be sent to Linus soon.
>
> Ok it will also fix Hugh's problem then.

It's in Linus' tree now. Hugh, can you please confirm it fixes your machine too?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

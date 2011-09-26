Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CCA949000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 06:03:42 -0400 (EDT)
Received: by bkbzs2 with SMTP id zs2so7278832bkb.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 03:03:40 -0700 (PDT)
Date: Mon, 26 Sep 2011 13:03:19 +0300 (EEST)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
In-Reply-To: <CAOtvUMfnrtonwbCn4j=weA-kjf4K0SG2YRwZ-Cy5XONNWyN_pQ@mail.gmail.com>
Message-ID: <alpine.LFD.2.02.1109261300200.15514@tux.localdomain>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com> <1316940890-24138-6-git-send-email-gilad@benyossef.com> <CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com> <1317022565.9084.60.camel@twins>
 <CAOtvUMfnrtonwbCn4j=weA-kjf4K0SG2YRwZ-Cy5XONNWyN_pQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On Mon, 26 Sep 2011, Gilad Ben-Yossef wrote:
> Peter basically already answered better then I could :-)
>
> All I have to add is an example -
>
> flush_all() is called for each kmem_cahce_destroy(). So every cache
> being destroyed dynamically ends up sending an IPI to each CPU in the
> system, regardless if the cache has ever been used there.
>
> For example, if you close the Infinband ipath driver char device file,
> the close file ops calls kmem_cache_destroy().So, if I understand
> correctly, running some infiniband config tool on one a single CPU
> dedicated to system tasks might interrupt the rest of the 127 CPUs I
> dedicated to some CPU intensive task. This is the scenario I'm
> tryingto avoid.
>
> I suspect there is a good chance that every line in the output of "git
> grep kmem_cache_destroy linux/ | grep '\->'" has a similar scenario
> (there are 42 of them).
>
> I hope this sheds some light on the motive of the work.

Sure.

If you write down such information in the changelog for future patches, I 
don't need to waste your time asking for an explanation. ;-)

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

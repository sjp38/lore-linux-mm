Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 203CF6B009C
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 13:26:35 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id w5so675987qac.6
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 10:26:34 -0800 (PST)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id s4si552570qan.27.2014.02.25.10.26.33
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 10:26:34 -0800 (PST)
Date: Tue, 25 Feb 2014 12:26:31 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [LSF/MM ATTEND] slab cache extension -- slab cache in fixed
 size
In-Reply-To: <530C0F08.1040000@oracle.com>
Message-ID: <alpine.DEB.2.10.1402251225280.30822@nuc>
References: <52D662A4.1080502@oracle.com> <alpine.DEB.2.10.1401310941430.6849@nuc> <530C0F08.1040000@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>

On Tue, 25 Feb 2014, Jeff Liu wrote:

> In this case, another thing I'm hesitating about whether to export the cache_limit
> via /proc/slabinfo by extending its tunable fields -- the per-CPU slab cache limit
> and batchcount, as thus will change the user space interface and slabtop(1) need to
> be modified accordingly.

Can you move the code to handle /sys/kernel/slab into mm/slab_common.c and
then make slab use that? (Maybe a bit of a tough call but that has to be
done at some point).

Once you got a directly with settings per slab then its trivial to add
another field.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

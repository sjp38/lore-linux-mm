Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CD8726B01B5
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 02:34:24 -0400 (EDT)
Received: by bwz1 with SMTP id 1so1377498bwz.14
        for <linux-mm@kvack.org>; Mon, 07 Jun 2010 23:34:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1006072319330.31780@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com>
	<20100521211537.530913777@quilx.com>
	<alpine.DEB.2.00.1006071443120.10905@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006071729560.12482@router.home>
	<AANLkTikOKy6ZQQh2zORJDvGDE0golvyzsvlvDj-P5cur@mail.gmail.com>
	<alpine.DEB.2.00.1006072319330.31780@chino.kir.corp.google.com>
Date: Tue, 8 Jun 2010 09:34:23 +0300
Message-ID: <AANLkTikQhjlCPnwiK7AZo27Xb3h-Lj2JyCeqFQaVzpHX@mail.gmail.com>
Subject: Re: [RFC V2 SLEB 01/14] slab: Introduce a constant for a unspecified
	node.
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

On Tue, 8 Jun 2010, Pekka Enberg wrote:
>> > Ok will do that in the next release.
>>
>> Patches 1-5 are queued for 2.6.36 so please send an incremental patch
>> on top of 'slub/cleanups' branch of slab.git.

On Tue, Jun 8, 2010 at 9:20 AM, David Rientjes <rientjes@google.com> wrote:
> An incremental patch in this case would change everything that the
> original patch did, so it'd probably be best to simply revert and queue
> the updated version.

If I revert it, we end up with two commits instead of one. And I
really prefer not to *rebase* a topic branch even though it might be
doable for a small tree like slab.git.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

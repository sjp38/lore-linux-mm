Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 57F89900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 07:44:58 -0400 (EDT)
Received: by vwm42 with SMTP id 42so2100494vwm.14
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 04:44:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E353F6B.1030501@parallels.com>
References: <20110720121612.28888.38970.stgit@localhost6>
	<alpine.DEB.2.00.1107201611010.3528@tiger>
	<20110720134342.GK5349@suse.de>
	<alpine.DEB.2.00.1107200854390.32737@router.home>
	<1311170893.2338.29.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1107200950270.1472@router.home>
	<1311174562.2338.42.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E353F6B.1030501@parallels.com>
Date: Sun, 31 Jul 2011 14:44:57 +0300
Message-ID: <CAOJsxLEfKOEtv2DaM=8uMPPM5iP45A92fs=CE949TScHSkNgFA@mail.gmail.com>
Subject: Re: [PATCH] mm-slab: allocate kmem_cache with __GFP_REPEAT
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@parallels.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, Jul 31, 2011 at 2:41 PM, Konstantin Khlebnikov
<khlebnikov@parallels.com> wrote:
> It seems someone forgot this patch,

[snip]

>> [PATCH] slab: remove one NR_CPUS dependency
>>
>> Reduce high order allocations in do_tune_cpucache() for some setups.
>> (NR_CPUS=3D4096 -> =A0we need 64KB)

It's queued in slab/urgent branch and will be sent to Linus tonight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

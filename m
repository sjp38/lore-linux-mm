Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 653CB6B0022
	for <linux-mm@kvack.org>; Fri, 13 May 2011 02:16:26 -0400 (EDT)
Received: by yxt33 with SMTP id 33so1084317yxt.14
        for <linux-mm@kvack.org>; Thu, 12 May 2011 23:16:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305230652.2575.72.camel@mulgrave.site>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	<1305127773-10570-4-git-send-email-mgorman@suse.de>
	<alpine.DEB.2.00.1105120942050.24560@router.home>
	<1305213359.2575.46.camel@mulgrave.site>
	<alpine.DEB.2.00.1105121024350.26013@router.home>
	<1305214993.2575.50.camel@mulgrave.site>
	<1305215742.27848.40.camel@jaguar>
	<1305225467.2575.66.camel@mulgrave.site>
	<1305229447.2575.71.camel@mulgrave.site>
	<1305230652.2575.72.camel@mulgrave.site>
Date: Fri, 13 May 2011 09:16:24 +0300
Message-ID: <BANLkTindTdL9a4VxZk_AXrWLQf6QWqjz5g@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

Hi,

On Thu, May 12, 2011 at 11:04 PM, James Bottomley
<James.Bottomley@hansenpartnership.com> wrote:
> Confirmed, I'm afraid ... I can trigger the problem with all three
> patches under PREEMPT. =A0It's not a hang this time, it's just kswapd
> taking 100% system time on 1 CPU and it won't calm down after I unload
> the system.

OK, that's good to know. I'd still like to take patches 1-2, though. Mel?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

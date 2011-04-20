Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D7DC68D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 01:53:45 -0400 (EDT)
Received: by vws4 with SMTP id 4so495525vws.14
        for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:53:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110420102314.4604.A69D9226@jp.fujitsu.com>
References: <1303249716.11237.26.camel@mulgrave.site>
	<alpine.DEB.2.00.1104191657030.26867@router.home>
	<20110420102314.4604.A69D9226@jp.fujitsu.com>
Date: Wed, 20 Apr 2011 08:53:41 +0300
Message-ID: <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Christoph Lameter <cl@linux.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Wed, Apr 20, 2011 at 4:23 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
> I'm worry about this patch. A lot of mm code assume !NUMA systems
> only have node 0. Not only SLUB.

So is that a valid assumption or not? Christoph seems to think it is
and James seems to think it's not. Which way should we aim to fix it?
Would be nice if other people chimed in as we already know what James
and Christoph think.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

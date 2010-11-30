Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 58BC96B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:10:26 -0500 (EST)
Date: Tue, 30 Nov 2010 13:10:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Free memory never fully used, swapping
In-Reply-To: <20101130092534.82D5.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1011301309240.3134@router.home>
References: <20101125101803.F450.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1011260943220.12265@router.home> <20101130092534.82D5.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Simon Kirby <sim@hostway.ca>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010, KOSAKI Motohiro wrote:

> This?

Specifying a parameter to temporarily override to see if this has the
effect is ok. But this has worked for years now. There must be something
else going with with reclaim that causes these issues now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D848B6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 16:01:53 -0400 (EDT)
Date: Fri, 22 Oct 2010 15:01:46 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20101022184647.GH2160@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1010221501190.27439@router.home>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com> <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie> <alpine.DEB.2.00.1010221024080.20437@router.home>
 <20101022184647.GH2160@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010, Mel Gorman wrote:

> I considered it but thought the indirection would look tortured and
> hinder review. If we agree on the basic premise, I would do it as two
> patches. Would that suit?

Sure. Aside from that small nitpick.

Reviewed-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

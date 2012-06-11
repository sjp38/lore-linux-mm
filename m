Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 1F36E6B0146
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 11:01:19 -0400 (EDT)
Date: Mon, 11 Jun 2012 10:01:15 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 0/6][resend] mempolicy memory corruption fixlet
In-Reply-To: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
Message-ID: <alpine.DEB.2.00.1206110934200.31180@router.home>
References: <1339406250-10169-1-git-send-email-kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@google.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, stable@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Mon, 11 Jun 2012, kosaki.motohiro@gmail.com wrote:

> changes from v1: fix some typo of changelogs.

I still have a hard time with the changelogs. Will try to give you
hopefulyl better ones.

Again you need to CC Andi Kleen on this. He wrote most of the shared
mempolicy code (long time ago) and then Lee started tinkering with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

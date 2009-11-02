Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 089D36B0078
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:39:46 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C21CC82C6E9
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:46:10 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id zQ8F9NOM+cGp for <linux-mm@kvack.org>;
	Mon,  2 Nov 2009 11:46:10 -0500 (EST)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1ED2382C770
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:46:06 -0500 (EST)
Date: Mon, 2 Nov 2009 11:38:50 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] page allocator: Do not allow interrupts to use
 ALLOC_HARDER
In-Reply-To: <4AED9EB4.5080601@redhat.com>
Message-ID: <alpine.DEB.1.10.0911021138070.24535@V090114053VZO-1>
References: <1256650833-15516-1-git-send-email-mel@csn.ul.ie> <1256650833-15516-3-git-send-email-mel@csn.ul.ie> <20091027130924.fa903f5a.akpm@linux-foundation.org> <alpine.DEB.2.00.0910271411530.9183@chino.kir.corp.google.com> <20091031184054.GB1475@ucw.cz>
 <alpine.DEB.2.00.0910311248490.13829@chino.kir.corp.google.com> <20091031201158.GB29536@elf.ucw.cz> <alpine.DEB.2.00.0910311413160.25524@chino.kir.corp.google.com> <20091031222905.GA32720@elf.ucw.cz> <4AECC04B.9060808@redhat.com> <20091101073527.GB32720@elf.ucw.cz>
 <4AED9EB4.5080601@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Pavel Machek <pavel@ucw.cz>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, stable@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Stephan von Krawczynski <skraw@ithnet.com>, kernel-testers@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 1 Nov 2009, Rik van Riel wrote:

> > So what? As soon as they do that, they lose any guarantees, anyway.
>
> They might lose the absolute guarantee, but that's no reason
> not to give it our best effort!

Then its not realtime anymore. "Realtime" seems to be some wishy
washy marketing term that flexes in a variety of ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

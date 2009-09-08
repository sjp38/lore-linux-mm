Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7CA7B6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:33:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9B57982C38F
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:33:48 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 7ctjqcb3jwUq for <linux-mm@kvack.org>;
	Tue,  8 Sep 2009 11:33:48 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D6A4082C39D
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 11:33:43 -0400 (EDT)
Date: Tue, 8 Sep 2009 11:32:02 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [rfc] lru_add_drain_all() vs isolation
In-Reply-To: <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1>
Message-ID: <alpine.DEB.1.10.0909081124240.30203@V090114053VZO-1>
References: <20090908190148.0CC9.A69D9226@jp.fujitsu.com>  <1252405209.7746.38.camel@twins>  <20090908193712.0CCF.A69D9226@jp.fujitsu.com>  <1252411520.7746.68.camel@twins>  <alpine.DEB.1.10.0909081000100.15723@V090114053VZO-1> <1252419602.7746.73.camel@twins>
 <alpine.DEB.1.10.0909081110450.30203@V090114053VZO-1>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <onestero@redhat.com>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

The usefulness of a scheme like this requires:

1. There are cpus that continually execute user space code
   without system interaction.

2. There are repeated VM activities that require page isolation /
   migration.

The first page isolation activity will then clear the lru caches of the
processes doing number crunching in user space (and therefore the first
isolation will still interrupt). The second and following isolation will
then no longer interrupt the processes.

2. is rare. So the question is if the additional code in the LRU handling
can be justified. If lru handling is not time sensitive then yes.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

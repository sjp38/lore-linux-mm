Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 71DD16B0093
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 21:51:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6924bcv014820
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 11:04:38 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B1B445DE4D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:04:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E9E745DD76
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:04:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 67C6C1DB8037
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:04:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 90EEAE08001
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 11:04:33 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
In-Reply-To: <20090707104440.GB21747@infradead.org>
References: <20090707193015.7DCD.A69D9226@jp.fujitsu.com> <20090707104440.GB21747@infradead.org>
Message-Id: <20090709110342.2386.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 11:04:32 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, linux-mm@kvack.org, Olaf Weber <olaf@sgi.com>, "MASON, CHRISTOPHER" <CHRIS.MASON@oracle.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jul 07, 2009 at 07:33:04PM +0900, KOSAKI Motohiro wrote:
> > At least, I agree with Olaf. if you got someone's NAK in past thread,
> > Could you please tell me its url?
> 
> The previous thread was simply dead-ended and nothing happened.
> 

Can you remember this thread subject? sorry, I haven't remember it.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

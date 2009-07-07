Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 68C9D6B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 05:50:03 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n67AX7Fk001566
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 7 Jul 2009 19:33:09 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 89B0745DE7C
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:33:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 42E8F45DE70
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:33:06 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 009D61DB8037
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:33:05 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 970501DB803E
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 19:33:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] bump up nr_to_write in xfs_vm_writepage
In-Reply-To: <20090707101946.GB1934@infradead.org>
References: <bzyd48cc14d.fsf@fransum.emea.sgi.com> <20090707101946.GB1934@infradead.org>
Message-Id: <20090707193015.7DCD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  7 Jul 2009 19:33:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Olaf Weber <olaf@sgi.com>, Eric Sandeen <sandeen@redhat.com>, xfs mailing list <xfs@oss.sgi.com>, linux-mm@kvack.org, "MASON, CHRISTOPHER" <CHRIS.MASON@oracle.com>
List-ID: <linux-mm.kvack.org>

> On Tue, Jul 07, 2009 at 11:07:30AM +0200, Olaf Weber wrote:
> > If the nr_to_write calculation really yields a value that is too
> > small, shouldn't it be fixed elsewhere?
> 
> In theory it should.  But given the amazing feedback of the VM people
> on this I'd rather make sure we do get the full HW bandwith on large
> arrays instead of sucking badly and not just wait forever.

At least, I agree with Olaf. if you got someone's NAK in past thread,
Could you please tell me its url?




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

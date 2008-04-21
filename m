Date: Mon, 21 Apr 2008 17:24:04 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: OOM killer doesn't kill the right task....
In-Reply-To: <20080421070123.GM108924158@sgi.com>
References: <20080421070123.GM108924158@sgi.com>
Message-Id: <20080421172255.C45A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi David

> Running in a 512MB UML system without swap, XFSQA test 084 reliably
> kills the kernel completely as the OOM killer is unable to find a
> task to kill. log output is below.
> 
> I don't know when it started failing - ISTR this working just fine
> on 2.6.24 kernels.

Can you reproduce it on non UML box?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

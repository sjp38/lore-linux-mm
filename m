Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 15A446B0088
	for <linux-mm@kvack.org>; Mon, 25 May 2009 23:29:23 -0400 (EDT)
Date: Tue, 26 May 2009 12:29:34 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] Warn if we run out of swap space
Message-ID: <20090526032934.GC9188@linux-sh.org>
References: <alpine.DEB.1.10.0905221454460.7673@qirst.com> <20090524144056.0849.A69D9226@jp.fujitsu.com> <4A1A057A.3080203@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A1A057A.3080203@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Pavel Machek <pavel@ucw.cz>, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sun, May 24, 2009 at 07:42:02PM -0700, Randy Dunlap wrote:
> KOSAKI Motohiro wrote:
> >> +	if (!printed) {
> >> +		printed = 1;
> >> +		printk(KERN_WARNING "All of swap is in use. Some pages cannot be swapped out.");
> >> +	}
> > 
> > Why don't you use WARN_ONCE()?
> 
> Someone earlier in this patch thread (maybe Pavel?) commented that
> WARN_ONCE() would cause a stack dump and that would be too harsh,
> especially for users.  I.e., just the message is needed here, not a
> stack dump.
> 
Note that this is precisely what we have printk_once() for these days,
which will do what this patch is doing already. Of course if the variable
will be reset, then it is best left as is.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

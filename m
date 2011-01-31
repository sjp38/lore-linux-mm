Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 4F0B58D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:13:04 -0500 (EST)
Date: Tue, 1 Feb 2011 00:13:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: kswapd hung tasks in 2.6.38-rc1
Message-ID: <20110131231301.GP16981@random.random>
References: <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <1296507528.7797.4609.camel@nimitz>
 <1296513616.7797.4929.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296513616.7797.4929.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 02:40:16PM -0800, Dave Hansen wrote:
> Still not a very good data point, but I ran a heavy swap load for an
> hour or so without reproducing this.  But, it happened again after I
> enabled transparent huge pages.  I managed to get a sysrq-t dump out of
> it:
> 
> 	http://sr71.net/~dave/ibm/2.6.38-rc2-hang-0.txt
> 
> khugepaged is one of the three running tasks.  Note, I set both its
> sleep timeouts to zero to stress it out a bit.

sysrq+l? sysrq+t doesn't provide interesting info for running tasks.

> I'll keep trying to reproduce without THP.

BTW, do you have prove locking enabled? With recent git I get a
deadlock inside _raw_spin_unlock_irq with prove locking enabled and it
goes away when I disable it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

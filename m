Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 40D418D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:20:09 -0500 (EST)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0VN1iCL024634
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:01:45 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 99A2572805B
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:20:06 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0VNK6nt336396
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:20:06 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0VNK6UR031505
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 18:20:06 -0500
Subject: Re: kswapd hung tasks in 2.6.38-rc1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110131231301.GP16981@random.random>
References: 
	 <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	 <1296507528.7797.4609.camel@nimitz> <1296513616.7797.4929.camel@nimitz>
	 <20110131231301.GP16981@random.random>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 31 Jan 2011 15:20:03 -0800
Message-ID: <1296516003.7797.5061.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: CAI Qian <caiqian@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2011-02-01 at 00:13 +0100, Andrea Arcangeli wrote:
> On Mon, Jan 31, 2011 at 02:40:16PM -0800, Dave Hansen wrote:
> > Still not a very good data point, but I ran a heavy swap load for an
> > hour or so without reproducing this.  But, it happened again after I
> > enabled transparent huge pages.  I managed to get a sysrq-t dump out of
> > it:
> > 
> > 	http://sr71.net/~dave/ibm/2.6.38-rc2-hang-0.txt
> > 
> > khugepaged is one of the three running tasks.  Note, I set both its
> > sleep timeouts to zero to stress it out a bit.
> 
> sysrq+l? sysrq+t doesn't provide interesting info for running tasks.

I'll try to get a sysrq-l dump.

> > I'll keep trying to reproduce without THP.
> 
> BTW, do you have prove locking enabled? With recent git I get a
> deadlock inside _raw_spin_unlock_irq with prove locking enabled and it
> goes away when I disable it.

Nope:

$ grep PROVE ../mhp-build/x86_64-elm3b82/.config
# CONFIG_PROVE_LOCKING is not set

Full .config is here

	http://sr71.net/~dave/ibm/config-v2.6.38-rc2

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06CFF8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 17:40:27 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p0VMbmwC030852
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 15:37:48 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p0VMeHOI112580
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 15:40:17 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p0VMeHSj020383
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 15:40:17 -0700
Subject: Re: kswapd hung tasks in 2.6.38-rc1
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <1296507528.7797.4609.camel@nimitz>
References: 
	 <1150342867.83404.1295513748640.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
	 <1296507528.7797.4609.camel@nimitz>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Mon, 31 Jan 2011 14:40:16 -0800
Message-ID: <1296513616.7797.4929.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, aarcange <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2011-01-31 at 12:58 -0800, Dave Hansen wrote:
> On Thu, 2011-01-20 at 03:55 -0500, CAI Qian wrote:
> > When running LTP oom01 [1] testing, the allocation process stopped
> > processing right after starting to swap.
> 
> I'm seeing the same stuff, but on -rc2.  I thought it was
> transparent-hugepage-related, but I don't see much of a trace of it in
> the stack dumps.
> 
> http://sr71.net/~dave/ibm/config-v2.6.38-rc2
> 
> It happened to me as well around the time that things started to hit
> swap.

Still not a very good data point, but I ran a heavy swap load for an
hour or so without reproducing this.  But, it happened again after I
enabled transparent huge pages.  I managed to get a sysrq-t dump out of
it:

	http://sr71.net/~dave/ibm/2.6.38-rc2-hang-0.txt

khugepaged is one of the three running tasks.  Note, I set both its
sleep timeouts to zero to stress it out a bit.

I'll keep trying to reproduce without THP.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jAANfLBU008257
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 18:41:21 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jAANfFhE075748
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 16:41:15 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jAANfKJj002680
	for <linux-mm@kvack.org>; Thu, 10 Nov 2005 16:41:21 -0700
Subject: Re: [RFC] sys_punchhole()
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20051110153254.5dde61c5.akpm@osdl.org>
References: <1131664994.25354.36.camel@localhost.localdomain>
	 <20051110153254.5dde61c5.akpm@osdl.org>
Content-Type: text/plain
Date: Thu, 10 Nov 2005 15:41:02 -0800
Message-Id: <1131666062.25354.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: andrea@suse.de, hugh@veritas.com, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-11-10 at 15:32 -0800, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > We discussed this in madvise(REMOVE) thread - to add support 
> > for sys_punchhole(fd, offset, len) to complete the functionality
> > (in the future).
> > 
> > http://marc.theaimsgroup.com/?l=linux-mm&m=113036713810002&w=2
> > 
> > What I am wondering is, should I invest time now to do it ?
> 
> I haven't even heard anyone mention a need for this in the past 1-2 years.
> 
> > Or wait till need arises ? 
> 
> A long wait, I suspect..
> 

Okay. I guess, I will wait till someone needs it.

I am just trying to increase my chances of "getting my madvise(REMOVE)
patch into mainline" :)

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

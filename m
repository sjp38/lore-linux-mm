Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA20765
	for <linux-mm@kvack.org>; Mon, 21 Oct 2002 14:13:32 -0700 (PDT)
Message-ID: <3DB46DFA.DFEB2907@digeo.com>
Date: Mon, 21 Oct 2002 14:13:30 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: ZONE_NORMAL exhaustion (dcache slab)
References: <302190000.1035232837@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> My big NUMA box went OOM over the weekend and started killing things
> for no good reason (2.5.43-mm2). Probably running some background
> updatedb for locate thing, not doing any real work.
> 
> meminfo:
> 

Looks like a plain dentry leak to me.  Very weird.

Did the machine recover and run normally?

Was it possible to force the dcache to shrink? (a cat /dev/hda1
would do that nicely)

Is it reproducible?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

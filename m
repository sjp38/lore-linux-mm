Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B14366B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 09:16:25 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp05.au.ibm.com (8.14.4/8.13.1) with ESMTP id p4SDA9Ge005714
	for <linux-mm@kvack.org>; Sat, 28 May 2011 23:10:09 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4SDFkF1213130
	for <linux-mm@kvack.org>; Sat, 28 May 2011 23:15:46 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4SDGDvf001892
	for <linux-mm@kvack.org>; Sat, 28 May 2011 23:16:13 +1000
Date: Sat, 28 May 2011 18:46:06 +0530
From: Ankita Garg <ankita@in.ibm.com>
Subject: Re: [PATCH 00/10] mm: Linux VM Infrastructure to support Memory
 Power Management
Message-ID: <20110528131606.GA3416@in.ibm.com>
Reply-To: Ankita Garg <ankita@in.ibm.com>
References: <1306499498-14263-1-git-send-email-ankita@in.ibm.com>
 <20110528005640.9076c0b1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110528005640.9076c0b1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, svaidy@linux.vnet.ibm.com, thomas.abraham@linaro.org

Hi Andrew,

On Sat, May 28, 2011 at 12:56:40AM -0700, Andrew Morton wrote:
> On Fri, 27 May 2011 18:01:28 +0530 Ankita Garg <ankita@in.ibm.com> wrote:
> 
> > This patchset proposes a generic memory regions infrastructure that can be
> > used to tag boundaries of memory blocks which belongs to a specific memory
> > power management domain and further enable exploitation of platform memory
> > power management capabilities.
> 
> A couple of quick thoughts...
> 
> I'm seeing no estimate of how much energy we might save when this work
> is completed.  But saving energy is the entire point of the entire
> patchset!  So please spend some time thinking about that and update and
> maintain the [patch 0/n] description so others can get some idea of the
> benefit we might get from all of this.  That estimate should include an
> estimate of what proportion of machines are likely to have hardware
> which can use this feature and in what timeframe.
>

This patchset is definitely not for inclusion. The intention of this RFC
series is to convey the idea and demonstrate the intricacies of the VM
design. Partial Array Self-Refresh (PASR) is an upcoming technology that
is supported on some platforms today, but will be an important feature
in future platforms to conserve idle power consumed by memory subsystem.
Mobile devices that are predominantly in the standby state can exploit
PASR feature to partially turn off areas of memory that are free.

Unfortunately, at this point we are unable to provide an estimate of the
power savings, as the hardware platforms do not yet export information
about the underlying memory hardware topology. We are working on this
and hope to have some estimations in a month or two. However, will
evaluate the performance impact of the changes and share the same.

> IOW, if it saves one microwatt on 0.001% of machines, not interested ;)
> 
> 
> Also, all this code appears to be enabled on all machines?  So machines
> which don't have the requisite hardware still carry any additional
> overhead which is added here.  I can see that ifdeffing a feature like
> this would be ghastly but please also have a think about the
> implications of this and add that discussion also.  
> 
> If possible, it would be good to think up some microbenchmarks which
> probe the worst-case performance impact and describe those and present
> the results.  So others can gain an understanding of the runtime costs.
> 

-- 
Regards,
Ankita Garg (ankita@in.ibm.com)
Linux Technology Center
IBM India Systems & Technology Labs,
Bangalore, India

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

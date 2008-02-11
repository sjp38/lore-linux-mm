Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1BI2f5P017252
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 13:02:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1BI2e0W063206
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 11:02:40 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1BI2dNt008919
	for <linux-mm@kvack.org>; Mon, 11 Feb 2008 11:02:40 -0700
Subject: Re: [-mm PATCH] register_memory/unregister_memory clean ups
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20080211175425.GA28300@kroah.com>
References: <1202750598.25604.3.camel@dyn9047017100.beaverton.ibm.com>
	 <20080211175425.GA28300@kroah.com>
Content-Type: text/plain
Date: Mon, 11 Feb 2008 10:05:36 -0800
Message-Id: <1202753136.25604.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Greg KH <greg@kroah.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-02-11 at 09:54 -0800, Greg KH wrote:
> On Mon, Feb 11, 2008 at 09:23:18AM -0800, Badari Pulavarty wrote:
> > Hi Andrew,
> > 
> > While testing hotplug memory remove against -mm, I noticed
> > that unregister_memory() is not cleaning up /sysfs entries
> > correctly. It also de-references structures after destroying
> > them (luckily in the code which never gets used). So, I cleaned
> > up the code and fixed the extra reference issue.
> > 
> > Could you please include it in -mm ?
> 
> Want me to add this to my tree and send it in my next update for the
> driver core to Linus?
> 
> I'll be glad to do that.
> 
> thanks,
> 
> greg k-h

Please do. Only reason I wanted to push through -mm is, I didn't
test this with mainline (since I have patches in -mm for hotplug 
memory remove).

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

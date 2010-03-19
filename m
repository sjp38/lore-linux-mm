Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CB9F36B00B0
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 03:24:17 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e39.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2J7GCoN027381
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:16:12 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2J7Ntov053200
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:23:55 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2J7NsvL010198
	for <linux-mm@kvack.org>; Fri, 19 Mar 2010 01:23:55 -0600
Subject: Re: [PATCH][RF C/T/D] Unmapped page cache control - via boot
 parameter
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4B9F49F1.70202@redhat.com>
References: <20100315072214.GA18054@balbir.in.ibm.com>
	 <4B9DE635.8030208@redhat.com> <20100315080726.GB18054@balbir.in.ibm.com>
	 <4B9DEF81.6020802@redhat.com> <20100315091720.GC18054@balbir.in.ibm.com>
	 <4B9DFD9C.8030608@redhat.com> <4B9E810E.9010706@codemonkey.ws>
	 <4B9F49F1.70202@redhat.com>
Content-Type: text/plain
Date: Fri, 19 Mar 2010 00:23:52 -0700
Message-Id: <1268983432.10438.5685.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Anthony Liguori <anthony@codemonkey.ws>, balbir@linux.vnet.ibm.com, KVM development list <kvm@vger.kernel.org>, Rik van Riel <riel@surriel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-03-16 at 11:05 +0200, Avi Kivity wrote:
> > Not really.  In many cloud environments, there's a set of common 
> > images that are instantiated on each node.  Usually this is because 
> > you're running a horizontally scalable application or because you're 
> > supporting an ephemeral storage model.
> 
> But will these servers actually benefit from shared cache?  So the 
> images are shared, they boot up, what then?
> 
> - apache really won't like serving static files from the host pagecache
> - dynamic content (java, cgi) will be mostly in anonymous memory, not 
> pagecache
> - ditto for application servers
> - what else are people doing?

Think of an OpenVZ-style model where you're renting out a bunch of
relatively tiny VMs and they're getting used pretty sporadically.  They
either have relatively little memory, or they've been ballooned down to
a pretty small footprint.

The more you shrink them down, the more similar they become.  You'll end
up having things like init, cron, apache, bash and libc start to
dominate the memory footprint in the VM.

That's *certainly* a case where this makes a lot of sense.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3HNaIY6023122
	for <linux-mm@kvack.org>; Thu, 17 Apr 2008 19:36:18 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3HNaH7W219778
	for <linux-mm@kvack.org>; Thu, 17 Apr 2008 17:36:17 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3HNaGvL010739
	for <linux-mm@kvack.org>; Thu, 17 Apr 2008 17:36:17 -0600
Date: Thu, 17 Apr 2008 16:36:15 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Documentation: add node files to sysfs ABI
Message-ID: <20080417233615.GA24508@us.ibm.com>
References: <20080411234449.GE19078@us.ibm.com> <20080411234712.GF19078@us.ibm.com> <20080411234743.GG19078@us.ibm.com> <20080411234913.GH19078@us.ibm.com> <20080411235648.GA13276@suse.de> <20080412094118.GA7708@wotan.suse.de> <20080413034136.GA22686@suse.de> <20080414210506.GA6350@us.ibm.com> <20080417231617.GA18815@us.ibm.com> <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804171619340.12031@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Greg KH <gregkh@suse.de>, Nick Piggin <npiggin@suse.de>, wli@holomorphy.com, agl@us.ibm.com, luick@cray.com, Lee.Schermerhorn@hp.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.04.2008 [16:22:17 -0700], Christoph Lameter wrote:
> On Thu, 17 Apr 2008, Nishanth Aravamudan wrote:
> 
> > > Do you see a particular more-sysfs-way here, Greg?
> > 
> > So I've received no comments yet? Perhaps I should leave things the way
> > they are (per-node files in /sys/devices/system/node) and add
> > nr_hugepages to /sys/kernel?
> 
> The strange location of the node directories has always irked me.

But it's now part of the ABI? We'd have to deprecate the current
location and such. I'm ok with that, or maybe duplicating the
information for now, while deprecating the old location, but don't want
to spend the time doing that if we don't want it to be changed.

> > Do we want to put it in a subdirectory of /sys/kernel? What should the
> > subdir be called? "hugetlb" (refers to the implementation?) or
> > "hugepages"?
> 
> How about:
> 
> /sys/kernel/node<nr>/<node specific setting/status files> ?

That seems fine to me. I will work on it. However, as I mentioned in a
previous e-mail, the files in /sys/devices/system/node/node<nr>/
already violate the "one value per file" rule in several instances. I'm
guessing Greg won't want me moving the files and keeping that violation?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

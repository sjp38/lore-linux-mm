Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2BFB600044
	for <linux-mm@kvack.org>; Mon,  9 Aug 2010 16:48:54 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o79Kj8C2027993
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 14:45:08 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o79KmiuC209434
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 14:48:44 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o79Kq974011191
	for <linux-mm@kvack.org>; Mon, 9 Aug 2010 14:52:10 -0600
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 8/8] v5  Update memory-hotplug documentation
Date: Mon, 9 Aug 2010 13:48:41 -0700
References: <4C60407C.2080608@austin.ibm.com> <4C604C62.7060509@austin.ibm.com> <201008091344.37878.nacc@us.ibm.com>
In-Reply-To: <201008091344.37878.nacc@us.ibm.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201008091348.42256.nacc@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linuxppc-dev@lists.ozlabs.org
Cc: linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Monday, August 09, 2010 01:44:37 pm Nishanth Aravamudan wrote:
> On Monday, August 09, 2010 11:43:46 am Nathan Fontenot wrote:
> > Update the memory hotplug documentation to reflect the new behaviors of
> > memory blocks reflected in sysfs.
> 
> <snip>
> 
> > Index: linux-2.6/Documentation/memory-hotplug.txt
> > ===================================================================
> > --- linux-2.6.orig/Documentation/memory-hotplug.txt	2010-08-09 07:36:48.000000000 -0500
> > +++ linux-2.6/Documentation/memory-hotplug.txt	2010-08-09 07:59:54.000000000 -0500
> 
> <snip>
> 
> > -/sys/devices/system/memory/memoryXXX/phys_index
> > +/sys/devices/system/memory/memoryXXX/start_phys_index
> > +/sys/devices/system/memory/memoryXXX/end_phys_index
> >  /sys/devices/system/memory/memoryXXX/phys_device
> >  /sys/devices/system/memory/memoryXXX/state
> >  /sys/devices/system/memory/memoryXXX/removable
> > 
> > -'phys_index' : read-only and contains section id, same as XXX.
> 
> <snip>
> 
> > +'phys_index'      : read-only and contains section id of the first section
> 
> Shouldn't this be "start_phys_index"?

Ah, actually it's that the Documentation change doesn't seem to agree with
patch 2/8 ? That is, 2/8 leaves phys_index in place, but changes several
variables, while this patch indicates its removal?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

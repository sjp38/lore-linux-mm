Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6BEF96B004A
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 11:23:09 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8SF2auv000864
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 11:02:36 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SFHhg0319914
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 11:17:43 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SFHgjW018272
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 12:17:43 -0300
Subject: Re: [PATCH 0/8] v2 De-Couple sysfs memory directories from memory
 sections
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4CA1E338.6070201@redhat.com>
References: <4CA0EBEB.1030204@austin.ibm.com>  <4CA1E338.6070201@redhat.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 28 Sep 2010 08:17:36 -0700
Message-ID: <1285687056.19976.6155.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-09-28 at 14:44 +0200, Avi Kivity wrote:
> Why not update sysfs directory creation to be fast, for example by using 
> an rbtree instead of a linked list.  This fixes an implementation 
> problem in the kernel instead of working around it and creating a new ABI.
> 
> New ABIs mean old tools won't work, and new tools need to understand 
> both ABIs.

Just to be clear _these_ patches do not change the existing ABI.

They do add a new ABI: the end_phys_index file.  But, it is completely
redundant at the moment.  It could be taken out of these patches.

That said, fixing the directory creation speed is probably a worthwhile
endeavor too.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

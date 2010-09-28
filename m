Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D0B546B0047
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 11:21:40 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8SF6Yii011876
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 11:06:34 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8SFLcok344228
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 11:21:38 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8SFLapZ011105
	for <linux-mm@kvack.org>; Tue, 28 Sep 2010 12:21:38 -0300
Subject: Re: [PATCH 6/8] v2 Update node sysfs code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100928092919.GF14068@sgi.com>
References: <4CA0EBEB.1030204@austin.ibm.com>
	 <4CA0F00D.9000702@austin.ibm.com>  <20100928092919.GF14068@sgi.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 28 Sep 2010 08:21:33 -0700
Message-ID: <1285687293.19976.6172.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Nathan Fontenot <nfont@austin.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, Greg KH <greg@kroah.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-09-28 at 04:29 -0500, Robin Holt wrote:
> Also, I don't think I much care for the weirdness that occurs if a
> memory block spans two nodes.  I have not thought through how possible
> (or likely) this is, but the code certainly permits it.  If that were
> the case, how would we know which sections need to be taken offline,
> etc? 

Since the architecture is the one doing the memory_block_size_bytes()
override, I'd expect that the per-arch code knows enough to ensure that
this doesn't happen.  It's probably something to add to the
documentation or the patch descriptions.  "How should an architecture
define this?  When should it be overridden?"

It's just like the question of SECTION_SIZE.  What if a section spans a
node?  Well, they don't because the sections are a software concept and
we _define_ them to not be able to cross nodes.  If they do, just make
them smaller.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

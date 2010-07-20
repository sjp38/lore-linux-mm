Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9C12D6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 15:10:25 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e34.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6KJ29NY007509
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:02:09 -0600
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id o6KJAWqK207464
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:10:32 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6KJABGP002611
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 13:10:11 -0600
Subject: Re: [PATCH 2/8] v3 Add new phys_index properties
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4C45A3AB.6090407@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	 <4C451D92.6020406@austin.ibm.com>  <4C45A3AB.6090407@austin.ibm.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Tue, 20 Jul 2010 12:10:04 -0700
Message-ID: <1279653004.9207.296.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Tue, 2010-07-20 at 08:24 -0500, Nathan Fontenot wrote:
> Update the 'phys_index' properties of a memory block to include a
> 'start_phys_index' which is the same as the current 'phys_index' property.
> This also adds an 'end_phys_index' property to indicate the id of the
> last section in th memory block.
> 
> Patch updated to keep the name of the phys_index property instead of
> renaming it to start_phys_index.

KAME is right on this.  We should keep the old one if at all possible.  

The only other thing we might want to do is move 'phys_index' to
'start_phys_index', and make a new 'phys_index' that does a WARN_ONCE(),
gives a deprecated warning, then calls the new 'start_phys_index' code.

So, basically make the new, more clear name, but keep the old one for a
while and deprecate it.  Maybe we could get away with removing it in ten
years. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

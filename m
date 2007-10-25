Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PHZ0mF007228
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:35:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PHYmfP053268
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:34:54 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PHYmUD017433
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 11:34:48 -0600
Subject: Re: [PATCH 2/2] Add mem_type in /syfs to show memblock migrate type
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
References: <1193327756.9894.5.camel@dyn9047017100.beaverton.ibm.com>
	 <1193331162.4039.141.camel@localhost>
	 <1193332042.9894.10.camel@dyn9047017100.beaverton.ibm.com>
	 <1193332528.4039.156.camel@localhost>
	 <1193333766.9894.16.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 10:34:43 -0700
Message-Id: <1193333683.4039.176.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, melgor@ie.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 10:36 -0700, Badari Pulavarty wrote:
> 
> > That's a good point.  But, if we have multiple _removable_ pageblocks in
> > the same section, but with slightly different types, your patch doesn't
> > help.  The user will just see "Multiple", and won't be able to tell that
> > they can remove it. :(
> 
> So, what you would like to see is - instead of mem_type, you want 
> "mem_removable" and print "true/false". Correct ?

Yup.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9VKsqi4024635
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 16:54:52 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9VLtBgq125168
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 15:55:11 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9VLtAea013281
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 15:55:11 -0600
Subject: Re: [PATCH 1/3] Add remove_memory() for ppc64
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1193868715.17412.55.camel@dyn9047017100.beaverton.ibm.com>
References: <1193849375.17412.34.camel@dyn9047017100.beaverton.ibm.com>
	 <1193863502.6271.38.camel@localhost>
	 <1193868715.17412.55.camel@dyn9047017100.beaverton.ibm.com>
Content-Type: text/plain
Date: Wed, 31 Oct 2007 14:55:03 -0700
Message-Id: <1193867703.6271.42.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@ozlabs.org, anton@au1.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-31 at 14:11 -0800, Badari Pulavarty wrote:
> 
> Well, We don't need arch-specific remove_memory() for ia64 and ppc64.
> x86_64, I don't know. We will know, only when some one does the
> verification. I don't need arch_remove_memory() hook also at this
> time.

I wasn't being very clear.  I say, add the arch hook only if you need
it.  But, for now, just take the ia64 code and make it generic.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

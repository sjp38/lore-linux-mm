Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9SKO8J8285000
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 16:24:08 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9SKO8QU442260
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 14:24:08 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9SKO7Gk019651
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 14:24:07 -0600
Message-ID: <41815566.9030507@us.ibm.com>
Date: Thu, 28 Oct 2004 13:24:06 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
References: <20041026092535.GE24462@logos.cnet> <20041026.230110.21315175.taka@valinux.co.jp> <20041026122419.GD27014@logos.cnet> <20041027.224837.118287069.taka@valinux.co.jp> <20041028151928.GA7562@logos.cnet> <20041028160520.GB7562@logos.cnet> <41813FCD.3070503@us.ibm.com> <20041028162652.GC7562@logos.cnet>
In-Reply-To: <20041028162652.GC7562@logos.cnet>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, iwamoto@valinux.co.jp, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Marcelo Tosatti wrote:
> Yeah I think page_migration() will be more conformant to the current
> macros.
> 
> Will do it, and upgrade to the latest -mhp. What is it again? 

http://sprucegoose.sr71.net/patches/2.6.9-mm1-mhp1/
http://sprucegoose.sr71.net/patches/patch-2.6.9-mm1-mhp1.gz

I have one against 2.6.10-rc1-mm1, but it's not quite ready yet.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

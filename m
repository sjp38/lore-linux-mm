Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA283KK6002015
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 03:03:20 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id jA283KXg359516
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 01:03:20 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA283JB6007512
	for <linux-mm@kvack.org>; Wed, 2 Nov 2005 01:03:20 -0700
Message-ID: <436880E5.3070003@de.ibm.com>
Date: Wed, 02 Nov 2005 10:03:33 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: Fwd: Re: VM_XIP Request for comments
References: <200510281155.03466.christian@borntraeger.net>	 <43621CFE.5080900@de.ibm.com> <6934efce0510280933q20fe304cra10d7594c1104d20@mail.gmail.com>
In-Reply-To: <6934efce0510280933q20fe304cra10d7594c1104d20@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: carsteno@de.ibm.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jared Hulbert wrote:
> I don't want to use EXT2.  I want to use linear cramfs (no block
> device) or something brand new.  Under these circumstances I don't
> need a block device driver right?
> 
No. Your filesystem needs to implement the vm operation get_xip_page,
and that's it,

-- 

Carsten Otte
IBM Linux technology center
ARCH=s390

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

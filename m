Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9PJv4Yb029964
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 15:57:04 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9PJv45k125492
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:57:04 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9PJv3dH032476
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 13:57:04 -0600
Subject: Re: RFC/POC Make Page Tables Relocatable
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
	 <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 25 Oct 2007 12:56:53 -0700
Message-Id: <1193342213.24087.66.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-10-25 at 15:53 -0400, Ross Biro wrote:
> 
> > My guys says that this is way too complicated to be pursued in this
> > form.  But, don't listen to me.  You don't have to convince _me_.

Wow.  My fingers no workee today.  "My gut says"...  I don't have a
bunch of guys sitting around telling me things (only in my head).

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

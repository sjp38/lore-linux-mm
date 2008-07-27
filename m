Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m6R3EIUT019313
	for <linux-mm@kvack.org>; Sat, 26 Jul 2008 23:14:19 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6R3EIrp105860
	for <linux-mm@kvack.org>; Sat, 26 Jul 2008 23:14:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m6R3EIUg003783
	for <linux-mm@kvack.org>; Sat, 26 Jul 2008 23:14:18 -0400
Subject: Re: How to get a sense of VM pressure
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <200807261425.26318.nickpiggin@yahoo.com.au>
References: <488A1398.7020004@goop.org>
	 <200807261425.26318.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Sat, 26 Jul 2008 20:14:12 -0700
Message-Id: <1217128452.23502.4.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Virtualization Mailing List <virtualization@lists.osdl.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2008-07-26 at 14:25 +1000, Nick Piggin wrote:
> Google I think and maybe IBM (can't remember) is using the proc pagemap
> interfaces to help with this. Probably it is super secret code that can't
> be released though -- but it gives you somewhere to look.

Nobody at IBM that I know. :)  I have other nefarious purposes for it,
but not for memory pressure.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

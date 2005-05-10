Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4AJgUDn027567
	for <linux-mm@kvack.org>; Tue, 10 May 2005 15:42:30 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4AJgUum118724
	for <linux-mm@kvack.org>; Tue, 10 May 2005 15:42:30 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4AJgUKp017780
	for <linux-mm@kvack.org>; Tue, 10 May 2005 15:42:30 -0400
Date: Tue, 10 May 2005 12:42:25 -0700
From: mike kravetz <kravetz@us.ibm.com>
Subject: Re: sparsemem ppc64 tidy flat memory comments and fix benign mempresent call
Message-ID: <20050510194225.GD3915@w-mikek2.ibm.com>
References: <E1DVAVE-00012m-Pq@pinky.shadowen.org> <427FEC57.8060505@austin.ibm.com> <4280D72C.4090203@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4280D72C.4090203@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: jschopp@austin.ibm.com, akpm@osdl.org, anton@samba.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc64-dev@ozlabs.org, olof@lixom.net, paulus@samba.org
List-ID: <linux-mm.kvack.org>

On Tue, May 10, 2005 at 04:45:48PM +0100, Andy Whitcroft wrote:
> Joel, Mike, Dave could you test this one on your platforms to confirm
> its widly applicable, if so we can push it up to -mm.

It works on my machine with various config options.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Received: from westrelay04.boulder.ibm.com (westrelay04.boulder.ibm.com [9.17.193.32])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iA31hu1p709582
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 20:44:07 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iA31hlF9133470
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 18:43:47 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iA31hkGK005457
	for <linux-mm@kvack.org>; Tue, 2 Nov 2004 18:43:46 -0700
Message-ID: <418837D1.402@us.ibm.com>
Date: Tue, 02 Nov 2004 17:43:45 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: fix iounmap and a pageattr memleak (x86 and x86-64)
References: <4187FA6D.3070604@us.ibm.com> <20041102220720.GV3571@dualathlon.random> <41880E0A.3000805@us.ibm.com> <4188118A.5050300@us.ibm.com> <20041103013511.GC3571@dualathlon.random>
In-Reply-To: <20041103013511.GC3571@dualathlon.random>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@suse.de>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> On Tue, Nov 02, 2004 at 03:00:26PM -0800, Dave Hansen wrote:
> 
>>just sent out, I just wanted to demonstrate what solves my immediate 
>>problem.
> 
> sure ;)
> 
> that's like disabling the config option, the only point of
> change_page_attr is to split the direct mapping, it does nothing on
> highmem, it actually BUGS() (and it wasn't one of my new bugs ;):
> 
> #ifdef CONFIG_HIGHMEM
> 	if (page >= highmem_start_page) 
> 		BUG(); 
> #endif

Oh, crap.  I meant to clear ->mapped when change_attr(__pgprot(0)) was 
done on it, and set it when it was changed back.  Doing that correctly 
preserves the symmetry, right?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

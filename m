Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3D6946B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 17:02:07 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate7.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n2CL23TU053360
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:02:03 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2CL23gl1888454
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:02:03 GMT
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2CL22Mf012313
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 21:02:03 GMT
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
 do?
From: Greg Kurz <gkurz@fr.ibm.com>
In-Reply-To: <20090312145311.GC12390@us.ibm.com>
References: <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	 <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <1234479845.30155.220.camel@nimitz>
	 <20090226155755.GA1456@x200.localdomain>
	 <20090310215305.GA2078@x200.localdomain> <49B775B4.1040800@free.fr>
	 <20090312145311.GC12390@us.ibm.com>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 22:01:59 +0100
Message-Id: <1236891719.32630.14.camel@bahia>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Cedric Le Goater <legoater@free.fr>, Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, tglx@linutronix.de, viro@zeniv.linux.org.uk, hpa@zytor.com, mingo@elte.hu, torvalds@linux-foundation.org, Alexey Dobriyan <adobriyan@gmail.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-03-12 at 09:53 -0500, Serge E. Hallyn wrote:
> Or are you suggesting that you'll do a dummy clone of (5594,2) so that
> the next clone(CLONE_NEWPID) will be expected to be (5594,3,1)?
> 

Of course not but one should be able to tell clone() to pick a specific
pid.

-- 
Gregory Kurz                                     gkurz@fr.ibm.com
Software Engineer @ IBM/Meiosys                  http://www.ibm.com
Tel +33 (0)534 638 479                           Fax +33 (0)561 400 420

"Anarchy is about taking complete responsibility for yourself."
        Alan Moore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

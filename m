Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D2B6B6B005D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 11:15:03 -0500 (EST)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1RGC5cV012661
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 11:12:05 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n1RGF13d128644
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 11:15:01 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1RGF06W022515
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 11:15:01 -0500
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090226223112.GA2939@x200.localdomain>
References: <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	 <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <1234479845.30155.220.camel@nimitz>
	 <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu>
	 <20090226223112.GA2939@x200.localdomain>
Content-Type: text/plain
Date: Fri, 27 Feb 2009 08:14:58 -0800
Message-Id: <1235751298.26788.372.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-27 at 01:31 +0300, Alexey Dobriyan wrote:
> > I think the main question is: will we ever find ourselves in the 
> > future saying that "C/R sucks, nobody but a small minority uses 
> > it, wish we had never merged it"? I think the likelyhood of that 
> > is very low. I think the current OpenVZ stuff already looks very 
> > useful, and i dont think we've realized (let alone explored) all 
> > the possibilities yet.
> 
> This is collecting and start of dumping part of cleaned up OpenVZ C/R
> implementation, FYI.

Are you just posting this to show how you expect c/r to look eventually?
Or are you proposing this as an alternative to what Oren has bee
posting?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

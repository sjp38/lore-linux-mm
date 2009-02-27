Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D73476B003D
	for <linux-mm@kvack.org>; Fri, 27 Feb 2009 16:51:08 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so661371fgg.4
        for <linux-mm@kvack.org>; Fri, 27 Feb 2009 13:51:07 -0800 (PST)
Date: Sat, 28 Feb 2009 00:57:49 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: How much of a mess does OpenVZ make? ;) Was: What can OpenVZ
	do?
Message-ID: <20090227215749.GA3453@x200.localdomain>
References: <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090212141014.2cd3d54d.akpm@linux-foundation.org> <1234479845.30155.220.camel@nimitz> <20090226162755.GB1456@x200.localdomain> <20090226173302.GB29439@elte.hu> <20090226223112.GA2939@x200.localdomain> <1235751298.26788.372.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1235751298.26788.372.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, tglx@linutronix.de, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 27, 2009 at 08:14:58AM -0800, Dave Hansen wrote:
> On Fri, 2009-02-27 at 01:31 +0300, Alexey Dobriyan wrote:
> > > I think the main question is: will we ever find ourselves in the 
> > > future saying that "C/R sucks, nobody but a small minority uses 
> > > it, wish we had never merged it"? I think the likelyhood of that 
> > > is very low. I think the current OpenVZ stuff already looks very 
> > > useful, and i dont think we've realized (let alone explored) all 
> > > the possibilities yet.
> > 
> > This is collecting and start of dumping part of cleaned up OpenVZ C/R
> > implementation, FYI.
> 
> Are you just posting this to show how you expect c/r to look eventually?
> Or are you proposing this as an alternative to what Oren has bee
> posting?

This is under discussion right now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

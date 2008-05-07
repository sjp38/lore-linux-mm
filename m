Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m47IC9Nt007682
	for <linux-mm@kvack.org>; Wed, 7 May 2008 14:12:09 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m47IC95F456220
	for <linux-mm@kvack.org>; Wed, 7 May 2008 14:12:09 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m47IC9wu026985
	for <linux-mm@kvack.org>; Wed, 7 May 2008 14:12:09 -0400
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
From: Matt Helsley <matthltc@us.ibm.com>
In-Reply-To: <20080507131712.GA8580@sergelap.austin.ibm.com>
References: <20080211141646.948191000@bull.net>
	 <20080211141813.354484000@bull.net>
	 <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
	 <481EC917.6070808@bull.net>
	 <1FE6DD409037234FAB833C420AA843EC014392F9@orsmsx424.amr.corp.intel.com>
	 <20080506180527.GA8315@sergelap.austin.ibm.com> <48214007.7050800@bull.net>
	 <20080507131712.GA8580@sergelap.austin.ibm.com>
Content-Type: text/plain
Date: Wed, 07 May 2008 11:12:07 -0700
Message-Id: <1210183927.7323.402.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: Nadia Derbey <Nadia.Derbey@bull.net>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cmm@us.ibm.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-07 at 08:17 -0500, Serge E. Hallyn wrote:
> Quoting Nadia Derbey (Nadia.Derbey@bull.net):
> > Serge E. Hallyn wrote:
> >> Quoting Luck, Tony (tony.luck@intel.com):
> >>>> Well, this printk had been suggested by somebody (sorry I don't remember 
> >>>> who) when I first submitted the patch. Actually I think it might be 
> >>>> useful for a sysadmin to be aware of a change in the msgmni value: we 
> >>>> have the message not only at boot time, but also each time msgmni is 
> >>>> recomputed because of a change in the amount of memory.
> >>>
> >>> If the message is directed at the system administrator, then it would
> >>> be nice if there were some more meaningful way to show the namespace
> >>> that is affected than just printing the hex address of the kernel 
> >>> structure.
> >>>
> >>> As the sysadmin for my test systems, printing the hex address is mildly
> >>> annoying ... I now have to add a new case to my scripts that look at
> >>> dmesg output for unusual activity.
> >>>
> >>> Is there some better "name for a namespace" than the address? Perhaps
> >>> the process id of the process that instantiated the namespace???
> >> I agree with Tony here.  Aside from the nuisance it is to see that
> >> message on console every time I unshare a namespace, a printk doesn't
> >> seem like the right way to output the info.
> >
> > But you agree that this is happening only because you're doing tests 
> > related to namespaces, right?
> 
> Yup :)
> 
> > I don't think that in a "standard" configuration this will happen very 
> > frequently, but may be I'm wrong.
> >
> >>  At most I'd say an audit
> >> message.
>
> > That's a good idea. Thanks, Serge. I'll do that.

	I'm not familiar with kernel policies regarding audit messages. Are
audit messages treated anything like kernel interfaces when it comes to
removing/changing them?

Cheers,
	-Matt Helsley

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

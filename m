Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5B2EB6B0082
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 14:10:48 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o93I6f7H025563
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 12:06:41 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o93IAlCC219866
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 12:10:47 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o93IAkLY003175
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 12:10:46 -0600
Date: Sun, 3 Oct 2010 23:40:44 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][RESEND] nommu: add anonymous page memcg accounting
Message-ID: <20101003181044.GG7896@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1285929315-2856-1-git-send-email-steve@digidescorp.com>
 <5206.1285943095@redhat.com>
 <WC20101001143139.810346@digidescorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <WC20101001143139.810346@digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: Steve Magnani <steve@digidescorp.com>
Cc: David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Steve Magnani <steve@digidescorp.com> [2010-10-01 09:31:39]:

> David Howells <dhowells@redhat.com> wrote:
> > 
> > Do we really need to do memcg accounting in NOMMU mode?  Might it be
> > better to just apply the attached patch instead?
> > 
> > David
> > ---
> > diff --git a/init/Kconfig b/init/Kconfig
> > index 2de5b1c..aecff10 100644
> > --- a/init/Kconfig
> > +++ b/init/Kconfig
> > @@ -555,7 +555,7 @@ config RESOURCE_COUNTERS
> >  
> >  config CGROUP_MEM_RES_CTLR
> >  	bool "Memory Resource Controller for Control Groups"
> > -	depends on CGROUPS && RESOURCE_COUNTERS
> > +	depends on CGROUPS && RESOURCE_COUNTERS && MMU
> >  	select MM_OWNER
> >  	help
> >  	  Provides a memory resource controller that manages both anonymous
> 
> If anything I think nommu is one of the better applications of memcg. Since nommu typically == 
> embedded, being able to put potential memory pigs in a sandbox so they can't destabilize the 
> system is a Good Thing. That was my motivation for doing this in the first place and it works 
> quite well.

Good to know, but I want to point out that I never explictly tested it
for NOMMU when I created memcg. I thought like the rest that not
having reclaim capability would limit memcg usage in the NOMMU world.


-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

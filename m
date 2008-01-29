Date: Tue, 29 Jan 2008 11:34:12 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/2] Relax restrictions on setting CONFIG_NUMA on x86
Message-ID: <20080129113411.GA962@csn.ul.ie>
References: <20080118153529.12646.5260.sendpatchset@skynet.skynet.ie> <20080121093702.8FC2.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123105810.F295.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080123102332.GB21455@csn.ul.ie> <2f11576a0801260610m29f4e7ecle9828d8bbaa462cd@mail.gmail.com> <20080126171803.GA29252@csn.ul.ie> <2f11576a0801262254i55cb2c96q40023aa0e53bffce@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0801262254i55cb2c96q40023aa0e53bffce@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On (27/01/08 15:54), KOSAKI Motohiro didst pronounce:
> Hi Mel
> 
> > > my patch stack is
> > >   2.6.24-rc7 +
> > >   http://lkml.org/lkml/2007/8/24/220 +
> >
> > Can you replace this patch with the patch below instead and try again
> > please? This is the patch that is actually in git-x86. Out of
> > curiousity, have you tried the latest mm branch from git-x86?
> 
> to be honest, I didn't understand usage of git, sorry.

It's ok. Ingo sent you a helpful guide. In it, it covers how to check
out the mm branch; see this part

#
# Check out the latest x86 branch:
#
git-checkout x86/mm

This is the branch that contains all the latest patches. You should *not*
need to patch it further. If your machine fails to boot this branch then
I'll need to roll a debugging patch. Before I do that, I want to be sure
you are testing the right branch.

Thanks for persisting. I know this is a little frustrating.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

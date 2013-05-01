Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 3EEEE6B0175
	for <linux-mm@kvack.org>; Wed,  1 May 2013 05:03:42 -0400 (EDT)
Date: Wed, 1 May 2013 04:03:38 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] mm: mmu_notifier: re-fix freed page still mapped in
 secondary MMU
Message-ID: <20130501090338.GP3658@sgi.com>
References: <516D275C.8040406@linux.vnet.ibm.com>
 <20130416112553.GM3658@sgi.com>
 <20130416114322.GN3658@sgi.com>
 <516D4D08.9020602@linux.vnet.ibm.com>
 <20130416180835.GY3658@sgi.com>
 <516E0F1E.5090805@linux.vnet.ibm.com>
 <20130417141035.GA29872@sgi.com>
 <516EECDB.6090400@linux.vnet.ibm.com>
 <20130417184523.GN3672@sgi.com>
 <516EEF6F.8060905@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <516EEF6F.8060905@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Robin Holt <holt@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi.kivity@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, KVM <kvm@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, Apr 18, 2013 at 02:52:31AM +0800, Xiao Guangrong wrote:
> On 04/18/2013 02:45 AM, Robin Holt wrote:
> 
> >>>>>>> For the v3.10 release, we should work on making this more
> >>>>>>> correct and completely documented.
> >>>>>>
> >>>>>> Better document is always welcomed.
> >>>>>>
> >>>>>> Double call ->release is not bad, like i mentioned it in the changelog:
> >>>>>>
> >>>>>> it is really rare (e.g, can not happen on kvm since mmu-notify is unregistered
> >>>>>> after exit_mmap()) and the later call of multiple ->release should be
> >>>>>> fast since all the pages have already been released by the first call.
> >>>>>>
> >>>>>> But, of course, it's great if you have a _light_ way to avoid this.
> >>>>>
> >>>>> Getting my test environment set back up took longer than I would have liked.
> >>>>>
> >>>>> Your patch passed.  I got no NULL-pointer derefs.
> >>>>
> >>>> Thanks for your test again.
> >>>>
> >>>>>
> >>>>> How would you feel about adding the following to your patch?
> >>>>
> >>>> I prefer to make these changes as a separate patch, this change is the
> >>>> improvement, please do not mix it with bugfix.
> >>>
> >>> I think your "improvement" classification is a bit deceiving.  My previous
> >>> patch fixed the bug in calling release multiple times.  Your patch without
> >>> this will reintroduce that buggy behavior.  Just because the bug is already
> >>> worked around by KVM does not mean it is not a bug.
> >>
> >> As your tested, calling ->release() multiple times can work, but just make your
> >> testcase more _slower_. So your changes is trying to speed it up - it is a
> >> improvement.
> >>
> >> Well, _if_ it is really a bug, could you please do not fix two bugs in one patch?
> > 
> > The code, as is, does not call ->release() multiple times.  Your code
> > changes the behavior to call it multiple times.  You are introducing the
> > bug by your code changes.  Why not fix the bug you create in the patch
> > which creates it?
> 
> Andrew, your thought?
> 

What ever happened with this?

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

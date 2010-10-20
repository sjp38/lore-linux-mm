Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AE2546B00A0
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 08:49:25 -0400 (EDT)
Received: from [10.10.7.10] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001455652.msg
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 07:49:20 -0500
Subject: Re: [PATCH V2] nommu: add anonymous page memcg accounting
From: "Steven J. Magnani" <steve@digidescorp.com>
Reply-To: steve@digidescorp.com
In-Reply-To: <20101020091746.f0cc5dc2.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287491654-4005-1-git-send-email-steve@digidescorp.com>
	 <20101019154819.GC15844@balbir.in.ibm.com>
	 <1287512657.2500.31.camel@iscandar.digidescorp.com>
	 <20101020091746.f0cc5dc2.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 20 Oct 2010 07:49:17 -0500
Message-ID: <1287578957.2603.34.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2010-10-20 at 09:17 +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 19 Oct 2010 13:24:17 -0500
> "Steven J. Magnani" <steve@digidescorp.com> wrote:
> 
> > On Tue, 2010-10-19 at 21:18 +0530, Balbir Singh wrote:
> > > * Steven J. Magnani <steve@digidescorp.com> [2010-10-19 07:34:14]:
> > > > +
> > > > +At the present time, only anonymous pages are included in NOMMU memory cgroup
> > > > +accounting.
> > > 
> > > What is the reason for tracking just anonymous memory?
> > 
> > Tracking more than that is beyond my current scope, and perhaps of
> > limited benefit under an assumption that NOMMU systems don't usually
> > work with large files. The limitations of the implementation are
> > documented, so hopefully anyone who needs more functionality will know
> > that they need to implement it.
> > 
> 
> What happens at reaching limit ? memory can be reclaimed ?

I'm not quite sure what you're asking. In my usage, the OOM-killer gets
invoked and the 'runaway' dosfsck process gets terminated; at that point
all its memory is freed. 

Regards,
------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

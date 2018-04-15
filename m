Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9549C6B0007
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 13:37:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id a125so8918515qkd.4
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 10:37:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k67si1584627qke.56.2018.04.15.10.37.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Apr 2018 10:37:15 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3FHZAjv062496
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 13:37:14 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hc2rs644r-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 13:37:14 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 15 Apr 2018 18:37:11 +0100
Date: Sun, 15 Apr 2018 20:36:56 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 00/32] docs/vm: convert to ReST format
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180329154607.3d8bda75@lwn.net>
 <20180401063857.GA3357@rapoport-lnx>
 <20180413135551.0e6d1b12@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180413135551.0e6d1b12@lwn.net>
Message-Id: <20180415173655.GB31176@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 13, 2018 at 01:55:51PM -0600, Jonathan Corbet wrote:
> Sorry for the silence, I'm pedaling as fast as I can, honest...
> 
> On Sun, 1 Apr 2018 09:38:58 +0300
> Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> 
> > My thinking was to start with mechanical RST conversion and then to start
> > working on the contents and ordering of the documentation. Some of the
> > existing files, e.g. ksm.txt, can be moved as is into the appropriate
> > places, others, like transhuge.txt should be at least split into admin/user
> > and developer guides.
> > 
> > Another problem with many of the existing mm docs is that they are rather
> > developer notes and it wouldn't be really straight forward to assign them
> > to a particular topic.
> 
> All this sounds good.
> 
> > I believe that keeping the mm docs together will give better visibility of
> > what (little) mm documentation we have and will make the updates easier.
> > The documents that fit well into a certain topic could be linked there. For
> > instance:
> 
> ...but this sounds like just the opposite...?  
> 
> I've had this conversation with folks in a number of subsystems.
> Everybody wants to keep their documentation together in one place - it's
> easier for the developers after all.  But for the readers I think it's
> objectively worse.  It perpetuates the mess that Documentation/ is, and
> forces readers to go digging through all kinds of inappropriate material
> in the hope of finding something that tells them what they need to know.
> 
> So I would *really* like to split the documentation by audience, as has
> been done for a number of other kernel subsystems (and eventually all, I
> hope).
> 
> I can go ahead and apply the RST conversion, that seems like a step in
> the right direction regardless.  But I sure hope we don't really have to
> keep it as an unorganized jumble of stuff...

I didn't mean we should keep it as unorganized jumble of stuff and I agree
that splitting the documentation by audience is better because developers
are already know how to find it :)

I just thought that putting the doc into the place should not be done
immediately after mechanical ReST conversion but rather after improving the
contents. Although I'd agree that part of the documentation in
Documentation/vm is in pretty good shape already.

 
> Thanks,
> 
> jon
> 

-- 
Sincerely yours,
Mike.

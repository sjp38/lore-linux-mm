Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA7A6B026F
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 08:41:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id s18-v6so4528604edr.15
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 05:41:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 7-v6si7981117edm.229.2018.08.01.05.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Aug 2018 05:41:56 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w71Cespj143398
	for <linux-mm@kvack.org>; Wed, 1 Aug 2018 08:41:54 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kkbm3bv5t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:41:54 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 1 Aug 2018 13:41:51 +0100
Date: Wed, 1 Aug 2018 15:41:45 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] um: switch to NO_BOOTMEM
References: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180731133827.GC23494@rapoport-lnx>
 <1574741.Uvo42kyWiX@blindfold>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1574741.Uvo42kyWiX@blindfold>
Message-Id: <20180801124144.GF24836@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Jeff Dike <jdike@addtoit.com>, Michal Hocko <mhocko@kernel.org>, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Richard,

On Tue, Jul 31, 2018 at 09:03:35PM +0200, Richard Weinberger wrote:
> Am Dienstag, 31. Juli 2018, 15:38:27 CEST schrieb Mike Rapoport:
> > Any comments on this?
> > 
> > On Tue, Jul 24, 2018 at 04:23:12PM +0300, Mike Rapoport wrote:
> > > Hi,
> > > 
> > > These patches convert UML to use NO_BOOTMEM.
> > > Tested on x86-64.
> > > 
> > > Mike Rapoport (2):
> > >   um: setup_physmem: stop using global variables
> > >   um: switch to NO_BOOTMEM
> > > 
> > >  arch/um/Kconfig.common   |  2 ++
> > >  arch/um/kernel/physmem.c | 22 ++++++++++------------
> > >  2 files changed, 12 insertions(+), 12 deletions(-)
> 
> Acked-by: Richard Weinberger <richard@nod.at>

Thanks!

Can you please merge this through the uml tree?
 
> Thanks,
> //richard
> 

-- 
Sincerely yours,
Mike.

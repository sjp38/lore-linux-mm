Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A9C526B0008
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 15:03:44 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v24-v6so2134859wmh.5
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 12:03:44 -0700 (PDT)
Received: from lithops.sigma-star.at (lithops.sigma-star.at. [195.201.40.130])
        by mx.google.com with ESMTPS id g17-v6si14747503wrc.41.2018.07.31.12.03.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 12:03:43 -0700 (PDT)
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH 0/2] um: switch to NO_BOOTMEM
Date: Tue, 31 Jul 2018 21:03:35 +0200
Message-ID: <1574741.Uvo42kyWiX@blindfold>
In-Reply-To: <20180731133827.GC23494@rapoport-lnx>
References: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com> <20180731133827.GC23494@rapoport-lnx>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Jeff Dike <jdike@addtoit.com>, Michal Hocko <mhocko@kernel.org>, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Am Dienstag, 31. Juli 2018, 15:38:27 CEST schrieb Mike Rapoport:
> Any comments on this?
> 
> On Tue, Jul 24, 2018 at 04:23:12PM +0300, Mike Rapoport wrote:
> > Hi,
> > 
> > These patches convert UML to use NO_BOOTMEM.
> > Tested on x86-64.
> > 
> > Mike Rapoport (2):
> >   um: setup_physmem: stop using global variables
> >   um: switch to NO_BOOTMEM
> > 
> >  arch/um/Kconfig.common   |  2 ++
> >  arch/um/kernel/physmem.c | 22 ++++++++++------------
> >  2 files changed, 12 insertions(+), 12 deletions(-)

Acked-by: Richard Weinberger <richard@nod.at>

Thanks,
//richard

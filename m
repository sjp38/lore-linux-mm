Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C90F16B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:14:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t17-v6so270261edr.21
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 21:14:05 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t40-v6si522780edm.33.2018.07.25.21.14.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 21:14:04 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6Q4DZMx123923
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:14:02 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kf2bjrvka-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 00:14:02 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 26 Jul 2018 05:14:01 +0100
Date: Thu, 26 Jul 2018 07:13:54 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] hexagon: switch to NO_BOOTMEM
References: <1532496594-26353-1-git-send-email-rppt@linux.vnet.ibm.com>
 <20180726014457.GH12771@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180726014457.GH12771@codeaurora.org>
Message-Id: <20180726041353.GA8477@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Kuo <rkuo@codeaurora.org>
Cc: Michal Hocko <mhocko@kernel.org>, linux-hexagon@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 25, 2018 at 08:44:57PM -0500, Richard Kuo wrote:
> On Wed, Jul 25, 2018 at 08:29:54AM +0300, Mike Rapoport wrote:
> > This patch adds registration of the system memory with memblock, eliminates
> > bootmem initialization and converts early memory reservations from bootmem
> > to memblock.
> > 
> > Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > ---
> > v2: fix calculation of the reserved memory size
> > 
> >  arch/hexagon/Kconfig   |  3 +++
> >  arch/hexagon/mm/init.c | 20 ++++++++------------
> >  2 files changed, 11 insertions(+), 12 deletions(-)
> > 
> 
> Looks good, I can take this through my tree.
 
Thanks. The hexagon tree seems the most appropriate :)
 
> Acked-by: Richard Kuo <rkuo@codeaurora.org>
> 

-- 
Sincerely yours,
Mike.

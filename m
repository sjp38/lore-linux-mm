Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 72B166B000A
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:38:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s18-v6so3506850edr.15
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 06:38:38 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s19-v6si6493538edc.383.2018.07.31.06.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 06:38:36 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6VDJFbu111705
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:38:35 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2kjqapmdu6-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 09:38:35 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 31 Jul 2018 14:38:33 +0100
Date: Tue, 31 Jul 2018 16:38:27 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] um: switch to NO_BOOTMEM
References: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <20180731133827.GC23494@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>
Cc: Michal Hocko <mhocko@kernel.org>, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Any comments on this?

On Tue, Jul 24, 2018 at 04:23:12PM +0300, Mike Rapoport wrote:
> Hi,
> 
> These patches convert UML to use NO_BOOTMEM.
> Tested on x86-64.
> 
> Mike Rapoport (2):
>   um: setup_physmem: stop using global variables
>   um: switch to NO_BOOTMEM
> 
>  arch/um/Kconfig.common   |  2 ++
>  arch/um/kernel/physmem.c | 22 ++++++++++------------
>  2 files changed, 12 insertions(+), 12 deletions(-)
> 
> -- 
> 2.7.4
> 

-- 
Sincerely yours,
Mike.

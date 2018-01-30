Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D36686B0008
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:55:05 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id k11so10875001qth.23
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 04:55:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t126si3893288qkb.474.2018.01.30.04.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jan 2018 04:55:05 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0UCsjo3133710
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:55:04 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ftqv4uh7f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 07:55:02 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 30 Jan 2018 12:54:50 -0000
Date: Tue, 30 Jan 2018 14:54:44 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] mm documentation
References: <20180130105237.GB7201@rapoport-lnx>
 <20180130105450.GC7201@rapoport-lnx>
 <20180130115055.GZ21609@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130115055.GZ21609@dhcp22.suse.cz>
Message-Id: <20180130125443.GA21333@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 30, 2018 at 12:50:55PM +0100, Michal Hocko wrote:
> On Tue 30-01-18 12:54:50, Mike Rapoport wrote:
> > (forgot to CC linux-mm)
> > 
> > On Tue, Jan 30, 2018 at 12:52:37PM +0200, Mike Rapoport wrote:
> > > Hello,
> > > 
> > > The mm kernel-doc documentation is not in a great shape. 
> > > 
> > > Some of the existing kernel-doc annotations were not reformatted during
> > > transition from dockbook to sphix. Sometimes the parameter descriptions
> > > do not match actual code. But aside these rather mechanical issues there
> > > are several points it'd like to discuss:
> > > 
> > > * Currently, only 14 files are linked to kernel-api.rst under "Memory
> > > Management in Linux" section. We have more than hundred files only in mm.
> > > Even the existing documentation is not generated when running "make
> > > htmldocs"
> 
> Is this documentation anywhere close to be actually useful?

Some parts are documented better, some worse. For instance, bootmem and
z3fold are covered not bad at all, but, say, huge_memory has no structured
comments at all. Roughly half of the files in mm/ have some documentation,
but I didn't yet read that all to say how much of it is actually useful.

And maybe having some skeleton for MM API in htmldocs with at least some
documentation will encourage people to look at the documentation.

> -- 
> Michal Hocko
> SUSE Labs
> 

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

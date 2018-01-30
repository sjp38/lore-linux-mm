Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C75B6B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 08:41:45 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id a6so266202wme.9
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 05:41:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b133si9492883wme.171.2018.01.30.05.41.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 05:41:43 -0800 (PST)
Date: Tue, 30 Jan 2018 14:41:41 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] mm documentation
Message-ID: <20180130134141.GD21609@dhcp22.suse.cz>
References: <20180130105237.GB7201@rapoport-lnx>
 <20180130105450.GC7201@rapoport-lnx>
 <20180130115055.GZ21609@dhcp22.suse.cz>
 <20180130125443.GA21333@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130125443.GA21333@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue 30-01-18 14:54:44, Mike Rapoport wrote:
> On Tue, Jan 30, 2018 at 12:50:55PM +0100, Michal Hocko wrote:
> > On Tue 30-01-18 12:54:50, Mike Rapoport wrote:
> > > (forgot to CC linux-mm)
> > > 
> > > On Tue, Jan 30, 2018 at 12:52:37PM +0200, Mike Rapoport wrote:
> > > > Hello,
> > > > 
> > > > The mm kernel-doc documentation is not in a great shape. 
> > > > 
> > > > Some of the existing kernel-doc annotations were not reformatted during
> > > > transition from dockbook to sphix. Sometimes the parameter descriptions
> > > > do not match actual code. But aside these rather mechanical issues there
> > > > are several points it'd like to discuss:
> > > > 
> > > > * Currently, only 14 files are linked to kernel-api.rst under "Memory
> > > > Management in Linux" section. We have more than hundred files only in mm.
> > > > Even the existing documentation is not generated when running "make
> > > > htmldocs"
> > 
> > Is this documentation anywhere close to be actually useful?
> 
> Some parts are documented better, some worse. For instance, bootmem and
> z3fold are covered not bad at all, but, say, huge_memory has no structured
> comments at all. Roughly half of the files in mm/ have some documentation,
> but I didn't yet read that all to say how much of it is actually useful.

It is good to hear that at least something has a documentation coverage.
I was asking mostly because I _think_ that the API documentation is far
from the top priority. We are seriously lacking any highlevel one which
describes the design and subsytems interaction. Well, we have missed
that train years ago. It will be really hard to catch up.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

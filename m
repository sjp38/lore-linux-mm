Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 26C13828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:14:29 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 63so5356210pfe.3
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:14:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id 76si58453615pfb.3.2016.03.02.06.14.28
        for <linux-mm@kvack.org>;
        Wed, 02 Mar 2016 06:14:28 -0800 (PST)
Date: Wed, 2 Mar 2016 09:14:26 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160302141426.GM3730@linux.intel.com>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
 <20160301214403.GJ3730@linux.intel.com>
 <1456871764.2369.59.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1456871764.2369.59.camel@HansenPartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org

On Tue, Mar 01, 2016 at 02:36:04PM -0800, James Bottomley wrote:
> On Tue, 2016-03-01 at 16:44 -0500, Matthew Wilcox wrote:
> > I think it's both.  I heard from one customer who calculated that 
> > with a 6TB server, mapping every page into a process would take ~24MB 
> > of page tables.  Multiply that by the 50,000 processes they expect to
> > run on a server of that size consumes 1.2TB of DRAM.  Using 1GB pages
> > reduces that by a factor of 512, down to 2GB.
> 
> This sounds a bit implausible:

Well, that's the customer workload.  They have terabytes of data, and they
want to map all of it into all 50k processes.  I know it's not how I use
my machine, but that's customers for you ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 7E1906B0253
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 16:47:22 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id w128so75483566pfb.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 13:47:22 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id tm2si32696219pac.109.2016.03.01.13.47.21
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 13:47:21 -0800 (PST)
Date: Tue, 1 Mar 2016 16:47:18 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301214718.GK3730@linux.intel.com>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301122036.GB19559@node.shutemov.name>
 <alpine.DEB.2.20.1603011025490.31696@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603011025490.31696@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Tue, Mar 01, 2016 at 10:32:52AM -0600, Christoph Lameter wrote:
> > >  - Can we get rid of PAGE_CACHE_SIZE now?  Finally?  Pretty please?
> >
> > +1 :)
> 
> We have had grandiouse visions of being free of that particular set of
> chains for more than 10 years now. Sadly nothing really was that appealing
> and the current state of THP support is not that encouraging as well. We
> rather go with static huge page support to have more control over how
> memory is laid out for a process.

With Kirill's fault-around code in place, I think it delivers all or most
of the benefits promised by increasing PAGE_CACHE_SIZE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

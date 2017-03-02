Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 273C46B0038
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 19:12:32 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id b2so73520005pgc.6
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 16:12:32 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id s81si5927805pgs.29.2017.03.01.16.12.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 16:12:31 -0800 (PST)
Date: Wed, 1 Mar 2017 16:12:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2 1/3] sparc64: NG4 memset 32 bits overflow
Message-ID: <20170302001228.GL16328@bombadil.infradead.org>
References: <1488327283-177710-1-git-send-email-pasha.tatashin@oracle.com>
 <1488327283-177710-2-git-send-email-pasha.tatashin@oracle.com>
 <87h93dhmir.fsf@firstfloor.org>
 <70b638b0-8171-ffce-c0c5-bdcbae3c7c46@oracle.com>
 <20170301151910.GH26852@two.firstfloor.org>
 <6a26815d-0ec2-7922-7202-b1e17d58aa00@oracle.com>
 <20170301173136.GI26852@two.firstfloor.org>
 <1e7db21b-808d-1f47-e78c-7d55c543ae39@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e7db21b-808d-1f47-e78c-7d55c543ae39@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <pasha.tatashin@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, sparclinux@vger.kernel.org

On Wed, Mar 01, 2017 at 04:20:28PM -0500, Pasha Tatashin wrote:
> Hi Andi,
> 
> After thinking some more about this issue, I figured that I would not want
> to set default maximums.
> 
> Currently, the defaults are scaled with system memory size, which seems like
> the right thing to do to me. They are set to size hash tables one entry per
> page and, if a scale argument is provided, scale them down to 1/2, 1/4, 1/8
> entry per page etc.

I disagree that it's the right thing to do.  You want your dentry cache
to scale with the number of dentries in use.  Scaling with memory size
is a reasonable approximation for smaller memory sizes, but allocating
8GB of *hash table entries* for dentries is plainly ridiculous, no matter
how much memory you have.  You won't have half a billion dentries active
in most uses of such a large machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E34D56B0279
	for <linux-mm@kvack.org>; Wed, 24 May 2017 10:31:44 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y106so15959075wrb.14
        for <linux-mm@kvack.org>; Wed, 24 May 2017 07:31:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si27537014eda.119.2017.05.24.07.31.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 May 2017 07:31:43 -0700 (PDT)
Date: Wed, 24 May 2017 16:31:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Define KB, MB, GB, TB in core VM
Message-ID: <20170524143142.GA14715@dhcp22.suse.cz>
References: <20170522111742.29433-1-khandual@linux.vnet.ibm.com>
 <20170522141149.9ef84bb0713769f4af0383f0@linux-foundation.org>
 <20170523070227.GA27864@infradead.org>
 <09a6bafa-5743-425e-8def-bd9219cd756c@suse.cz>
 <161638da-3b2b-7912-2ae2-3b2936ca1537@linux.vnet.ibm.com>
 <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7f85724c-6fc1-bb51-11e4-15fc2f89372b@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 24-05-17 12:10:13, Anshuman Khandual wrote:
[...]
> So the question is are we willing to do all these changes across
> the tree to achieve common definitions of KB, MB, GB, TB in the
> kernel ? Is it worth ?

I do not think this is worth losing time. Any tree wide change should
have a considerable advantage in the end. These macro helpers do not
sound overly important to care. But that is just my 2c
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

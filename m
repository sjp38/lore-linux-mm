Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 735CC6B0035
	for <linux-mm@kvack.org>; Thu, 28 Aug 2014 12:50:43 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so3273509pab.31
        for <linux-mm@kvack.org>; Thu, 28 Aug 2014 09:50:42 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id se10si7706468pbb.72.2014.08.28.09.50.38
        for <linux-mm@kvack.org>;
        Thu, 28 Aug 2014 09:50:38 -0700 (PDT)
Date: Thu, 28 Aug 2014 12:50:12 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
Message-ID: <20140828165012.GK3285@linux.intel.com>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <20140827130613.c8f6790093d279a447196f17@linux-foundation.org>
 <20140827211250.GH3285@linux.intel.com>
 <20140827144622.ed81195a1d94799bb57a3207@linux-foundation.org>
 <53FE8633.10305@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53FE8633.10305@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 27, 2014 at 06:30:27PM -0700, Andy Lutomirski wrote:
> 4) No page faults ever once a page is writable (I hope -- I'm not sure
> whether this series actually achieves that goal).

I can't think of a circumstance in which you'd end up taking a page fault
after a writable mapping is established.

The next part to this series (that I'm working on now) is PMD support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

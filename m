Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 68E9D6B0366
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 17:17:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so218965014pgc.1
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:17:40 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id j190si4920472pgd.278.2016.11.17.14.17.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 14:17:39 -0800 (PST)
Date: Thu, 17 Nov 2016 15:17:38 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH 00/29] Improve radix tree for 4.10
Message-ID: <20161117221738.GA2738@linux.intel.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
 <1479341856-30320-37-git-send-email-mawilcox@linuxonhyperv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1479341856-30320-37-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Nov 16, 2016 at 04:17:01PM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Hi Andrew,
> 
> Please include these patches in the -mm tree for 4.10.  Mostly these are
> improvements; the only bug fixes in here relate to multiorder entries
> (which as far as I'm aware remain unused).  

My DAX PMD patches use multiorder entries, and are queued for v4.10 merge:

http://www.spinics.net/lists/linux-fsdevel/msg104041.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

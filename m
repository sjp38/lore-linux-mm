Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 12D886B0036
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 17:36:47 -0400 (EDT)
Received: by mail-yh0-f54.google.com with SMTP id b6so6855599yha.27
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 14:36:46 -0700 (PDT)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id c68si131465yhl.131.2014.09.04.14.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 04 Sep 2014 14:36:46 -0700 (PDT)
Date: Thu, 4 Sep 2014 17:36:41 -0400
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH v10 19/21] xip: Add xip_zero_page_range
Message-ID: <20140904213641.GB4364@thunk.org>
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>
 <80c8efc903971eb3a338f262fbd3ef135db63eb0.1409110741.git.matthew.r.wilcox@intel.com>
 <20140903092116.GF20473@dastard>
 <20140904210802.GA27730@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140904210802.GA27730@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Sep 04, 2014 at 05:08:02PM -0400, Matthew Wilcox wrote:
> 
> ext4 does (or did?) have this bug (expectation?).  I then take advantage
> of the fact that we have to accommodate it, so there are now two places
> that have to accommodate it.  I forget what the path was that has that
> assumption, but xfstests used to display it.
> 
> I'm away this week (... bad timing), but I can certainly fix it elsewhere
> in ext4 next week.

Huh?  Can you say more about what it is or was doing?  And where?

I tried to look for it, and I'm not seeing it, but I'm not entirely
sure from your description whether I'm looking in the right place.

Cheers,

     	       		   	       	       - Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

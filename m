Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 153046B0035
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 21:30:32 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id rd3so345580pab.31
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 18:30:31 -0700 (PDT)
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
        by mx.google.com with ESMTPS id yz5si3241628pbb.242.2014.08.27.18.30.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 27 Aug 2014 18:30:31 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so355996pab.29
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 18:30:30 -0700 (PDT)
Message-ID: <53FE8633.10305@amacapital.net>
Date: Wed, 27 Aug 2014 18:30:27 -0700
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH v10 00/21] Support ext4 on NV-DIMMs
References: <cover.1409110741.git.matthew.r.wilcox@intel.com>	<20140827130613.c8f6790093d279a447196f17@linux-foundation.org>	<20140827211250.GH3285@linux.intel.com> <20140827144622.ed81195a1d94799bb57a3207@linux-foundation.org>
In-Reply-To: <20140827144622.ed81195a1d94799bb57a3207@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@linux.intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/27/2014 02:46 PM, Andrew Morton wrote:
> I assume (because I wasn't told!) that there are two objectives here:
> 
> 1) reduce memory consumption by not maintaining pagecache and
> 2) reduce CPU cost by avoiding the double-copies.
> 
> These things are pretty easily quantified.  And really they must be
> quantified as part of the developer testing, because if you find
> they've worsened then holy cow, what went wrong.
> 

There are two more huge ones:

3) Writes via mmap are immediately durable (or at least they're durable
after a *very* lightweight flush).

4) No page faults ever once a page is writable (I hope -- I'm not sure
whether this series actually achieves that goal).

A note on #3: there is ongoing work to enable write-through memory for
things like this.  Once that's done, then writes via mmap might actually
be synchronously durable, depending on chipset details.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f171.google.com (mail-yk0-f171.google.com [209.85.160.171])
	by kanga.kvack.org (Postfix) with ESMTP id 4370E6B0005
	for <linux-mm@kvack.org>; Mon, 15 Feb 2016 19:45:41 -0500 (EST)
Received: by mail-yk0-f171.google.com with SMTP id u9so66994382ykd.1
        for <linux-mm@kvack.org>; Mon, 15 Feb 2016 16:45:41 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id e199si13191543ybh.224.2016.02.15.16.45.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Feb 2016 16:45:40 -0800 (PST)
Date: Mon, 15 Feb 2016 19:45:31 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160216004531.GA28260@thunk.org>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
 <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard>
 <56C264BF.3090100@cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <56C264BF.3090100@cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>
Cc: Dave Chinner <david@fromorbit.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, "Nag Avadhanam (nag)" <nag@cisco.com>

On Mon, Feb 15, 2016 at 03:52:31PM -0800, Daniel Walker wrote:
> >>We need it to determine accurately what the free memory in the
> >>system is. If you know where we can get this information already
> >>please tell, we aren't aware of it. For instance /proc/meminfo isn't
> >>accurate enough.
> 
> Approximate point-in-time indication is an accurate characterization
> of what we are doing. This is good enough for us. NO matter what we
> do, we are never going to be able to address the "time of check to
> time of usea?? window.  But, this approximation works reasonably well
> for our use case.

Why do you need such accuracy, and what do you consider "good enough".
Having something which iterates over all of the inodes in the system
is something that really shouldn't be in a general production kernel
At the very least it should only be accessible by root (so now only a
careless system administrator can DOS attack the system) but the
Dave's original question still stands.  Why do you need a certain
level of accuracy regarding how much memory is available after
dropping all of the caches?  What problem are you trying to
solve/avoid?

It may be that you are going about things completely the wrong way,
which is why understanding the higher order problem you are trying to
solve might be helpful in finding something which is safer,
architecturally cleaner, and something that could go into the upstream
kernel.

Cheers,

						- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AC30A6B0253
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 14:44:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a69so111435691pfa.1
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 11:44:23 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id st9si5281278pab.84.2016.07.08.11.38.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 11:38:26 -0700 (PDT)
Received: by mail-pa0-x22b.google.com with SMTP id hu1so2294669pad.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 11:38:25 -0700 (PDT)
Date: Fri, 8 Jul 2016 11:38:17 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 0/9] [REVIEW-REQUEST] [v4] System Calls for Memory
 Protection Keys
In-Reply-To: <20160707124719.3F04C882@viggo.jf.intel.com>
Message-ID: <alpine.LSU.2.11.1607081131350.28868@eggly.anvils>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, arnd@arndb.de, mgorman@techsingularity.net, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, 7 Jul 2016, Dave Hansen wrote:

> I'm resending these because Ingo has said that he'd "love to have
> some high level MM review & ack for these syscall ABI extensions."
> The only changes to the code in months have been in the selftests.
> So, if anyone has been putting off taking a look at these, I'd
> appreciate a look now.

Please expect nothing from me.  I've paid no attention to memory
protection keys, and they're way off my radar of interest.  Sorry,
if I spend my time looking at stuff I have little to contribute to,
then I'm left with no time at all for what I should really be doing.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

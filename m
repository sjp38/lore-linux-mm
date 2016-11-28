Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 582696B0069
	for <linux-mm@kvack.org>; Sun, 27 Nov 2016 19:58:45 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r101so222955777ioi.3
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 16:58:45 -0800 (PST)
Received: from mail-io0-x241.google.com (mail-io0-x241.google.com. [2607:f8b0:4001:c06::241])
        by mx.google.com with ESMTPS id 184si38785403iou.226.2016.11.27.16.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Nov 2016 16:58:44 -0800 (PST)
Received: by mail-io0-x241.google.com with SMTP id h133so19749523ioe.2
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 16:58:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161127224208.GA31101@dastard>
References: <1479926662-21718-1-git-send-email-ross.zwisler@linux.intel.com>
 <1479926662-21718-4-git-send-email-ross.zwisler@linux.intel.com>
 <20161124173220.GR1555@ZenIV.linux.org.uk> <20161125024918.GX31101@dastard>
 <20161125041419.GT1555@ZenIV.linux.org.uk> <20161125070642.GZ31101@dastard>
 <20161125073747.GU1555@ZenIV.linux.org.uk> <CA+55aFy5=74ad4tByQJYnkyX079z59yn02koJ_G8kfxamjvPDw@mail.gmail.com>
 <20161127224208.GA31101@dastard>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 27 Nov 2016 16:58:43 -0800
Message-ID: <CA+55aFwmCVZECoMszXZkJ8tSpG5+Ynt-5EKxKqDepNtjUv5vkg@mail.gmail.com>
Subject: Re: [PATCH 3/6] dax: add tracepoint infrastructure, PMD tracing
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Ross Zwisler <ross.zwisler@linux.intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Sun, Nov 27, 2016 at 2:42 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> And that's exactly why we need a method of marking tracepoints as
> stable. How else are we going to know whether a specific tracepoint
> is stable if the kernel code doesn't document that it's stable?

You are living in some unrealistic dream-world where you think you can
get the right tracepoint on the first try.

So there is no way in hell I would ever mark any tracepoint "stable"
until it has had a fair amount of use, and there are useful tools that
actually make use of it, and it has shown itself to be the right
trace-point.

And once that actually happens, what's the advantage of marking it
stable? None. It's a catch-22. Before it has uses and has been tested
and found to be good, it's not stable. And after, it's pointless.

So at no point does such a "stable" tracepoint marking make sense. At
most, you end up adding a comment saying "this tracepoint is used by
tools such-and-such".

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

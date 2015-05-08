Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DA15E6B0075
	for <linux-mm@kvack.org>; Fri,  8 May 2015 19:41:25 -0400 (EDT)
Received: by wgin8 with SMTP id n8so85047834wgi.0
        for <linux-mm@kvack.org>; Fri, 08 May 2015 16:41:25 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id ht6si1023517wib.102.2015.05.08.16.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 16:41:24 -0700 (PDT)
Received: by widdi4 with SMTP id di4so46510019wid.0
        for <linux-mm@kvack.org>; Fri, 08 May 2015 16:41:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150508134901.e3e7585b359b073253788c22@linux-foundation.org>
References: <cover.1431103461.git.tony.luck@intel.com>
	<20150508130307.e9bfedcfc66cbe6e6b009f19@linux-foundation.org>
	<CA+8MBbLNO5PdsdVtwweCuGohWkns2sCijkOCj4qHjo0HptEHFg@mail.gmail.com>
	<20150508134901.e3e7585b359b073253788c22@linux-foundation.org>
Date: Fri, 8 May 2015 16:41:23 -0700
Message-ID: <CA+8MBbJz79aSNRmfRJ2aEisQz10+zURfeu=GiHUofYDQyviP=w@mail.gmail.com>
Subject: Re: [PATCHv2 0/3] Find mirrored memory, use for boot time allocations
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, May 8, 2015 at 1:49 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> What I mean is: allow userspace to consume ZONE_MIRROR memory because
> we can snatch it back if it is needed for kernel memory.

For suitable interpretations of "snatch it back" ... if there is none
free in a GFP_NOWAIT request, then we are doomed.  But we
could maintain some high/low watermarks to arrange the snatching
when mirrored memory is getting low, rather than all the way out.

It's worth a look - but perhaps at phase three. It would make life
a bit easier for people to get the right amount of mirror. If they
guess too high they are still wasting some memory because
every mirrored page has two pages in DIMM. But without this
sort of trick all the extra mirrored memory would be totally wasted.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

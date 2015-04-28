Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE446B006C
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:38:02 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so8735175pab.3
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:38:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id m4si36579576pap.204.2015.04.28.15.38.01
        for <linux-mm@kvack.org>;
        Tue, 28 Apr 2015 15:38:01 -0700 (PDT)
Message-ID: <55400BC8.6080204@intel.com>
Date: Tue, 28 Apr 2015 15:38:00 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: PCID and TLB flushes (was: [GIT PULL] kdbus for 4.1-rc1)
References: <20150428221553.GA5770@node.dhcp.inet.fi>
In-Reply-To: <20150428221553.GA5770@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@amacapital.net>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org

On 04/28/2015 03:15 PM, Kirill A. Shutemov wrote:
> On Tue, Apr 28, 2015 at 01:42:10PM -0700, Andy Lutomirski wrote:
>> At some point, I'd like to implement PCID on x86 (if no one beats me
>> to it, and this is a low priority for me), which will allow us to skip
>> expensive TLB flushes while context switching.  I have no idea whether
>> ARM can do something similar.
> 
> I talked with Dave about implementing PCID and he thinks that it will be
> net loss. TLB entries will live longer and it means we would need to trigger
> more IPIs to flash them out when we have to. Cost of IPIs will be higher
> than benifit from hot TLB after context switch.
> 
> Do you have different expectations?

Kirill, I think Andy is asking about something different that what you
and I talked about.  My point to you was that PCIDs can not be used to
to replace or in lieu of TLB shootdowns because they *only* make TLB
entries live longer.

Their entire purpose is to make things live longer and to reduce the
cost of the implicit TLB shootdowns that we do as a part of a context
switch.

I'm not sure if it will have a benefit overall.  It depends on the
increase in shootdown cost vs. the decrease in TLB refill cost at
context switch.

I think someone hacked up some code to do it (maybe just internally to
Intel), so if anyone is seriously interested in implementing it, let me
know and I'll see if I can dig it up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

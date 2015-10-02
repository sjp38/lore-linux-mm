Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 61B274402F8
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:42:47 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so31623152wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:42:47 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id fy5si9859522wib.14.2015.10.02.06.42.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 06:42:46 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so33631766wic.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:42:46 -0700 (PDT)
Date: Fri, 2 Oct 2015 15:42:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
Message-ID: <20151002134243.GB16302@dhcp22.suse.cz>
References: <560D59F7.4070002@roeck-us.net>
 <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
 <560E8879.6050808@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560E8879.6050808@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>

On Fri 02-10-15 06:36:57, Guenter Roeck wrote:
> On 10/01/2015 01:49 PM, Andrew Morton wrote:
> >On Thu, 1 Oct 2015 09:06:15 -0700 Guenter Roeck <linux@roeck-us.net> wrote:
> >
> >>Seen with next-20151001, running qemu, simulating Opteron_G1 with a non-SMP configuration.
> >>On a re-run, I have seen it with the same image, but this time when simulating IvyBridge,
> >>so it is not CPU dependent. I did not previously see the problem.
> >>
> >>Log is at
> >>http://server.roeck-us.net:8010/builders/qemu-x86-next/builds/259/steps/qemubuildcommand/logs/stdio
> >>
> >>I'll try to bisect. The problem is not seen with every boot, so that may take a while.
> >
> >Caused by mhocko's "mm, fs: obey gfp_mapping for add_to_page_cache()",
> >I expect.
> >
> I tried to bisect to be sure, but the problem doesn't happen often enough, and I got some
> false negatives. I assume bisect is no longer necessary. If I need to try again, please
> let me know.

The updated patch has been posted here:
http://lkml.kernel.org/r/20151002085324.GA2927%40dhcp22.suse.cz

Andrew's analysis seems decent so I am pretty sure it should fix the
issue.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

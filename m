Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB6656B0294
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:37:04 -0400 (EDT)
Received: by obbda8 with SMTP id da8so81962934obb.1
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:37:04 -0700 (PDT)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id n8si5991723oev.81.2015.10.02.06.37.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 06:37:03 -0700 (PDT)
Subject: Re: linux-next: kernel BUG at mm/slub.c:1447!
References: <560D59F7.4070002@roeck-us.net>
 <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <560E8879.6050808@roeck-us.net>
Date: Fri, 2 Oct 2015 06:36:57 -0700
MIME-Version: 1.0
In-Reply-To: <20151001134904.127ccc7bea14e969fbfba0d5@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Dave Chinner <david@fromorbit.com>

On 10/01/2015 01:49 PM, Andrew Morton wrote:
> On Thu, 1 Oct 2015 09:06:15 -0700 Guenter Roeck <linux@roeck-us.net> wrote:
>
>> Seen with next-20151001, running qemu, simulating Opteron_G1 with a non-SMP configuration.
>> On a re-run, I have seen it with the same image, but this time when simulating IvyBridge,
>> so it is not CPU dependent. I did not previously see the problem.
>>
>> Log is at
>> http://server.roeck-us.net:8010/builders/qemu-x86-next/builds/259/steps/qemubuildcommand/logs/stdio
>>
>> I'll try to bisect. The problem is not seen with every boot, so that may take a while.
>
> Caused by mhocko's "mm, fs: obey gfp_mapping for add_to_page_cache()",
> I expect.
>
I tried to bisect to be sure, but the problem doesn't happen often enough, and I got some
false negatives. I assume bisect is no longer necessary. If I need to try again, please
let me know.

Thanks,
Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

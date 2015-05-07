Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0C72A6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 13:41:46 -0400 (EDT)
Received: by wgiu9 with SMTP id u9so50867404wgi.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 10:41:45 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id bn2si5070339wib.0.2015.05.07.10.41.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 10:41:44 -0700 (PDT)
Received: by wiun10 with SMTP id n10so355578wiu.1
        for <linux-mm@kvack.org>; Thu, 07 May 2015 10:41:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150506163016.a2d79f89abc7543cb80307ac@linux-foundation.org>
References: <cover.1430772743.git.tony.luck@intel.com>
	<ec15446621a86b74ab1c7237c8c3e21b0b3e0e06.1430772743.git.tony.luck@intel.com>
	<20150506163016.a2d79f89abc7543cb80307ac@linux-foundation.org>
Date: Thu, 7 May 2015 10:41:43 -0700
Message-ID: <CA+8MBbLrNq7Au8wsARCjXWzhaYCKimvf5soEw_tbX0gdSDBdUg@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/memblock: Allocate boot time data structures from
 mirrored memory
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, May 6, 2015 at 4:30 PM, Andrew Morton <akpm@linux-foundation.org> wrote:
> Gramatically, a function called "memblock_has_mirror()" should return a
> bool.  This guy is misnamed.  "memblock_mirror_flag()"?

My misnaming is worse than that ... the intent here is to check
whether there is any
mirrored memory in the system ... i.e. should we go looking around
among memblocks
for mirrored memory - or is that a futile quest.  Most systems won't
have any mirror
memory - so we won't want to spam the console logs with a ton of messages about
not being able to allocate mirrored memory.

I'll rename it to "system_has_mirror_memory()".

I'll fix all the other things too and re-spin.  Keeping to 80 columns
might be challenging in some places.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

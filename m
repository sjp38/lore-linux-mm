Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3083D6B0255
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 16:36:16 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id e32so76689283qgf.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:36:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 97si12059017qgt.89.2016.01.29.13.36.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 13:36:15 -0800 (PST)
Subject: Re: [PATCHv2 2/2] mm/page_poisoning.c: Allow for zero poisoning
References: <1454035099-31583-1-git-send-email-labbott@fedoraproject.org>
 <1454035099-31583-3-git-send-email-labbott@fedoraproject.org>
 <20160129104543.GA21224@amd>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <56ABDB4A.2040709@redhat.com>
Date: Fri, 29 Jan 2016 13:36:10 -0800
MIME-Version: 1.0
In-Reply-To: <20160129104543.GA21224@amd>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@denx.de>, Laura Abbott <labbott@fedoraproject.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Kees Cook <keescook@chromium.org>, linux-pm@vger.kernel.org

On 01/29/2016 02:45 AM, Pavel Machek wrote:
> Hi!
>
>> By default, page poisoning uses a poison value (0xaa) on free. If this
>> is changed to 0, the page is not only sanitized but zeroing on alloc
>> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
>> corruption from the poisoning is harder to detect. This feature also
>> cannot be used with hibernation since pages are not guaranteed to be
>> zeroed after hibernation.
>
> So... this makes kernel harder to debug for performance advantage...?
> If so.. how big is the performance advantage?
> 									Pavel
>

The performance advantage really depends on the benchmark you are running.
It was pointed out this may help some unknown amount with merging pages
in VMs since the pages are now identical and can be merged. The debugging
is also only slightly more difficult. With the non-zero poisoning value
it's easier to see that a crash was caused by triggering the poison vs.
just some random NULL pointer.

As as been pointed out, this help text could use some updating so I'll
clarify this more.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

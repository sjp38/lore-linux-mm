Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF7656B005A
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:42:05 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id v187so5283858qka.5
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:42:05 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id w206si1661932qka.269.2018.04.13.06.42.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:42:04 -0700 (PDT)
Subject: Re: [PATCH RFC 5/8] mm: only mark section offline when all pages are
 offline
References: <20180413133229.3257-1-david@redhat.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <be6c6b1c-6629-1b18-8a52-ac79e698cba6@redhat.com>
Date: Fri, 13 Apr 2018 15:42:01 +0200
MIME-Version: 1.0
In-Reply-To: <20180413133229.3257-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Ingo Molnar <mingo@kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, Dave Hansen <dave.hansen@linux.intel.com>, David Rientjes <rientjes@google.com>, open list <linux-kernel@vger.kernel.org>

On 13.04.2018 15:32, David Hildenbrand wrote:
> If any page is still online, the section should stay online.
> 
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---

This is a duplicate, please ignore.

(get_maintainers.sh and my mail server had a little clinch, so I had to
send half of the series out manually -_- )

-- 

Thanks,

David / dhildenb

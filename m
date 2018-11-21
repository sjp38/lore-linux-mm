Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDD6C6B239F
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 07:21:43 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 92so6353626qkx.19
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:21:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h8si8087376qta.340.2018.11.21.04.21.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Nov 2018 04:21:42 -0800 (PST)
Subject: Re: [PATCH v1 8/8] PM / Hibernate: exclude all PageOffline() pages
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-9-david@redhat.com>
 <11E3C0B0-AEED-42C6-A21C-1820F4B47A68@oracle.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <88f19102-9830-1ed0-1f46-56e11316ca09@redhat.com>
Date: Wed, 21 Nov 2018 13:21:08 +0100
MIME-Version: 1.0
In-Reply-To: <11E3C0B0-AEED-42C6-A21C-1820F4B47A68@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, "Michael S. Tsirkin" <mst@redhat.com>

On 21.11.18 12:35, William Kucharski wrote:
> If you are adding PageOffline(page) to the condition list of the already existing if in
> saveable_highmem_page(), why explicitly add it as a separate statement in saveable_page()?
> 
> It would seem more consistent to make the second check:
> 
> -	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page))
> +	if (swsusp_page_is_forbidden(page) || swsusp_page_is_free(page) ||
> +		PageOffline(page))
> 
> instead.
> 
> It's admittedly a nit but it just seems cleaner to either do that or, if your intention
> was to separate the Page checks from the swsusp checks, to break the calls to
> PageReserved() and PageOffline() into their own check in saveable_highmem_page().

I'll split PageReserved() and PageOffline() off from the swsusp checks,
thanks for your comment!

> 
> Thanks!
>     -- Bill


-- 

Thanks,

David / dhildenb

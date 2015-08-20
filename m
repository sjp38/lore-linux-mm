Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A3B4C6B0038
	for <linux-mm@kvack.org>; Thu, 20 Aug 2015 03:56:14 -0400 (EDT)
Received: by wijp15 with SMTP id p15so8326136wij.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:56:14 -0700 (PDT)
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com. [209.85.212.170])
        by mx.google.com with ESMTPS id mb10si7630164wic.100.2015.08.20.00.56.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Aug 2015 00:56:13 -0700 (PDT)
Received: by wibhh20 with SMTP id hh20so28690049wib.0
        for <linux-mm@kvack.org>; Thu, 20 Aug 2015 00:56:12 -0700 (PDT)
Date: Thu, 20 Aug 2015 09:56:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150820075611.GD4780@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz>
 <20150819213345.GB4536@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150819213345.GB4536@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed 19-08-15 17:33:45, Eric B Munson wrote:
[...]
> The group which asked for this feature here
> wants the ability to distinguish between LOCKED and LOCKONFAULT regions
> and without the VMA flag there isn't a way to do that.

Could you be more specific on why this is needed?

> Do we know that these last two open flags are needed right now or is
> this speculation that they will be and that none of the other VMA flags
> can be reclaimed?

I do not think they are needed by anybody right now but that is not a
reason why it should be used without a really strong justification.
If the discoverability is really needed then fair enough but I haven't
seen any justification for that yet.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

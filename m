Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4FF28028E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 08:50:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id y16so26323440wmd.6
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:50:24 -0800 (PST)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id ga4si10352596wjb.93.2016.11.11.05.50.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 05:50:23 -0800 (PST)
Date: Fri, 11 Nov 2016 13:50:11 +0000
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 1/2] shmem: Support for registration of driver/file owner
 specific ops
Message-ID: <20161111135011.GU9300@nuc-i3427.alporthouse.com>
References: <1478271776-1194-1-git-send-email-akash.goel@intel.com>
 <alpine.LSU.2.11.1611092057460.6221@eggly.anvils>
 <e2ba6054-c090-16a5-6a33-42b5061b16ba@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e2ba6054-c090-16a5-6a33-42b5061b16ba@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Goel, Akash" <akash.goel@intel.com>
Cc: Hugh Dickins <hughd@google.com>, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, linux-kernel@vger.linux.org, Sourab Gupta <sourab.gupta@intel.com>, akash.goels@gmail.com

On Thu, Nov 10, 2016 at 09:52:34PM +0530, Goel, Akash wrote:
> 
> 
> On 11/10/2016 11:06 AM, Hugh Dickins wrote:
> >On Fri, 4 Nov 2016, akash.goel@intel.com wrote:
> >>Cc: Hugh Dickins <hughd@google.com>
> >>Cc: linux-mm@kvack.org
> >>Cc: linux-kernel@vger.linux.org
> >>Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
> >>Signed-off-by: Akash Goel <akash.goel@intel.com>
> >>Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
> >
> >That doesn't seem quite right: the From line above implies that Chris
> >wrote it, and should be first Signer; but perhaps the From line is wrong.
> >
> Chris only wrote this patch initially, will do the required correction.

Akash is being modest. I gave him an idea I had been toying with to help
reduce premature oom, he is the one who deserves credit for turning it
into a functional patch and putting it into production.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

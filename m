Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f170.google.com (mail-ea0-f170.google.com [209.85.215.170])
	by kanga.kvack.org (Postfix) with ESMTP id 350196B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 21:37:15 -0500 (EST)
Received: by mail-ea0-f170.google.com with SMTP id g15so2312138eak.1
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 18:37:14 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id x43si35818029eey.103.2014.02.11.18.37.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 18:37:13 -0800 (PST)
Date: Wed, 12 Feb 2014 03:37:11 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Message-ID: <20140212023711.GT11821@two.firstfloor.org>
References: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
 <20140211211732.GS11821@two.firstfloor.org>
 <20140211163108.3136d55a@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140211163108.3136d55a@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com

> The real syntax is hugepagesnid=nid,nr-pages,size. Which looks straightforward
> to me. I honestly can't think of anything better than that, but I'm open for
> suggestions.

hugepages_node=nid:nr-pages:size,... ? 

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

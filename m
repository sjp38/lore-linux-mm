Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A4FC6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 14:37:44 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v2so5568229pfa.4
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 11:37:44 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id d10si7187857plo.388.2017.10.11.11.37.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Oct 2017 11:37:43 -0700 (PDT)
Date: Wed, 11 Oct 2017 11:37:41 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH 0/7 v1] Speed up page cache truncation
Message-ID: <20171011183741.GH5109@tassilo.jf.intel.com>
References: <20171010151937.26984-1-jack@suse.cz>
 <878tgisyo6.fsf@linux.intel.com>
 <20171011080658.GK3667@quack2.suse.cz>
 <e596a6d7-4858-8fe6-c315-8a285748a31a@intel.com>
 <20171011175945.nmlkso3fi6kqmhnu@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171011175945.nmlkso3fi6kqmhnu@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-fsdevel@vger.kernel.org

> Profiles appear to disagree but regardless of the explanation, the fact
> is that the series improves truncation quite a bit on my tests. From three
> separate machines running bonnie, I see the following gains.

The batching patches are a good idea in any case. I was just wondering if we could
get rid of the original 10% too. But it's not critical.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 769086B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:06:36 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id fl4so38281892pad.0
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:06:36 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id xe1si3430480pab.53.2016.02.12.10.06.35
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:06:35 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE1F2A.30103@intel.com>
Date: Fri, 12 Feb 2016 10:06:34 -0800
MIME-Version: 1.0
In-Reply-To: <56AAA77D.7090000@cisco.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 01/28/2016 03:42 PM, Daniel Walker wrote:
> My colleague Khalid and I are working on a patch which will provide a
> /proc file to output the size of the drop-able page cache.
> One way to implement this is to use the current drop_caches /proc
> routine, but instead of actually droping the caches just add
> up the amount.

Code, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

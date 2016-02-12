Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB3F6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:18:43 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id e127so51219074pfe.3
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:18:43 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id vv1si21373944pab.34.2016.02.12.10.18.42
        for <linux-mm@kvack.org>;
        Fri, 12 Feb 2016 10:18:42 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <56BE1F2A.30103@intel.com>
 <56BE2135.5040407@cisco.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56BE21EC.6030708@intel.com>
Date: Fri, 12 Feb 2016 10:18:20 -0800
MIME-Version: 1.0
In-Reply-To: <56BE2135.5040407@cisco.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Walker <danielwa@cisco.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 02/12/2016 10:15 AM, Daniel Walker wrote:
> On 02/12/2016 10:06 AM, Dave Hansen wrote:
>> On 01/28/2016 03:42 PM, Daniel Walker wrote:
>>> My colleague Khalid and I are working on a patch which will provide a
>>> /proc file to output the size of the drop-able page cache.
>>> One way to implement this is to use the current drop_caches /proc
>>> routine, but instead of actually droping the caches just add
>>> up the amount.
>> Code, please.
> 
> We have a process for release code which doesn't allow us to send it
> immediately. B

OK, how about we continue this discussion once you can release it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

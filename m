Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 497F06B0594
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 02:54:12 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id x5-v6so7749315pfn.22
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 23:54:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y7-v6si3156102pgi.256.2018.11.07.23.54.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Nov 2018 23:54:10 -0800 (PST)
Subject: Re: stable request: mm, page_alloc: actually ignore mempolicies for
 high priority allocations
References: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <08ae2e51-672a-37de-2aa6-4e49dbc9de02@suse.cz>
Date: Thu, 8 Nov 2018 08:54:07 +0100
MIME-Version: 1.0
In-Reply-To: <a66fb268-74fe-6f4e-a99f-3257b8a5ac3b@vyatta.att-mail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mmanning@vyatta.att-mail.com, stable@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

+CC linux-mm

On 11/7/18 6:33 PM, Mike Manning wrote:
> Hello, Please consider backporting to 4.14.y the following commit from
> kernel-net-next by Vlastimil Babka [CC'ed]:
> 
> d6a24df00638 ("mm, page_alloc: actually ignore mempolicies for high
> priority allocations") It cherry-picks cleanly and builds fine.
> 
> The reason for the request is that the commit 1d26c112959f
> <http://stash.eng.vyatta.net:7990/projects/VC/repos/linux-vyatta/commits/1d26c112959f>A ("mm,
> page_alloc:do not break __GFP_THISNODE by zonelist reset") that was
> previously backported to 4.14.y broke some of our functionality after we
> upgraded from an earlier 4.14 kernel without the fix.

Well, that's very surprising! Could you be more specific about what
exactly got broken?

> The reason this is
> happening is not clear, with this commit only found by bisect.
> Fortunately the requested commit resolves the issue.

I would like to understand the problem first, because I currently can't
imagine how the first commit could break something and the second fix it.

> Best Regards,
> 
> Mike Manning
> 

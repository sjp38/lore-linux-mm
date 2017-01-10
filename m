Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EBB76B0038
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 21:19:59 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 127so694756231pfg.5
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 18:19:59 -0800 (PST)
Received: from mail-pf0-x230.google.com (mail-pf0-x230.google.com. [2607:f8b0:400e:c00::230])
        by mx.google.com with ESMTPS id s68si444569plb.94.2017.01.09.18.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jan 2017 18:19:58 -0800 (PST)
Received: by mail-pf0-x230.google.com with SMTP id 127so37746090pfg.1
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 18:19:58 -0800 (PST)
Date: Mon, 9 Jan 2017 18:19:56 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: add new background defrag option
In-Reply-To: <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
Message-ID: <alpine.DEB.2.10.1701091818340.61862@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com> <20170105101330.bvhuglbbeudubgqb@techsingularity.net> <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz> <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz> <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com> <baeae644-30c4-5f99-2f99-6042766d7885@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jan 2017, Vlastimil Babka wrote:

> > Any suggestions for a better name for "background" are more than welcome.  
> 
> Why not just "madvise+defer"?
> 

Seeing no other activity regarding this issue (omg!), I'll wait a day or 
so to see if there are any objections to "madvise+defer" or suggestions 
that may be better and repost.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

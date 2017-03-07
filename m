Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E67936B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 09:19:37 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v66so1046985wrc.4
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:19:37 -0800 (PST)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id y132si19085222wme.36.2017.03.07.06.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 06:19:36 -0800 (PST)
Received: by mail-wr0-x244.google.com with SMTP id u48so432738wrc.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 06:19:36 -0800 (PST)
Date: Tue, 7 Mar 2017 17:19:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 01/11] mm: use SWAP_SUCCESS instead of 0
Message-ID: <20170307141933.GA2779@node.shutemov.name>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-2-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1488436765-32350-2-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Thu, Mar 02, 2017 at 03:39:15PM +0900, Minchan Kim wrote:
> SWAP_SUCCESS defined value 0 can be changed always so don't rely on
> it. Instead, use explict macro.

I'm okay with this as long as it's prepartion for something meaningful.
0 as success is widely used. I don't think replacing it's with macro here
has value on its own.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

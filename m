Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9E36B0038
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 05:49:16 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id q124so40827404wmg.2
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 02:49:16 -0800 (PST)
Received: from outbound-smtp09.blacknight.com (outbound-smtp09.blacknight.com. [46.22.139.14])
        by mx.google.com with ESMTPS id n54si13318652wrn.247.2017.02.13.02.49.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Feb 2017 02:49:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp09.blacknight.com (Postfix) with ESMTPS id ABA631C2344
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 10:49:14 +0000 (GMT)
Date: Mon, 13 Feb 2017 10:49:14 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH v2 01/10] mm, compaction: reorder fields in struct
 compact_control
Message-ID: <20170213104914.prmoetjh5ot64lvf@techsingularity.net>
References: <20170210172343.30283-1-vbabka@suse.cz>
 <20170210172343.30283-2-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170210172343.30283-2-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Feb 10, 2017 at 06:23:34PM +0100, Vlastimil Babka wrote:
> While currently there are (mostly by accident) no holes in struct
> compact_control (on x86_64), but we are going to add more bool flags, so place
> them all together to the end of the structure. While at it, just order all
> fields from largest to smallest.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

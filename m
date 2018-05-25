Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9577C6B0007
	for <linux-mm@kvack.org>; Fri, 25 May 2018 15:43:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id s3-v6so3474745pfh.0
        for <linux-mm@kvack.org>; Fri, 25 May 2018 12:43:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s13-v6si23831933plp.350.2018.05.25.12.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 12:43:02 -0700 (PDT)
Date: Fri, 25 May 2018 12:43:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: do not break __GFP_THISNODE by zonelist
 reset
Message-Id: <20180525124300.964a1a15d953e8972625bb0f@linux-foundation.org>
In-Reply-To: <20180525130853.13915-1-vbabka@suse.cz>
References: <20180525130853.13915-1-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, stable@vger.kernel.org

On Fri, 25 May 2018 15:08:53 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> we might consider this for 4.17 although I don't know if there's anything
> currently broken. Stable backports should be more important, but will have to
> be reviewed carefully, as the code went through many changes.
> BTW I think that also the ac->preferred_zoneref reset is currently useless if
> we don't also reset ac->nodemask from a mempolicy to NULL first (which we
> probably should for the OOM victims etc?), but I would leave that for a
> separate patch.

Confused.  If nothing is currently broken then why is a backport
needed?  Presumably because we expect breakage in the future?  Can you
expand on this?

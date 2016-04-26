Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 098756B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 07:31:59 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id j8so9798041lfd.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 04:31:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wp4si12507644wjb.173.2016.04.26.04.31.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 04:31:52 -0700 (PDT)
Subject: Re: [PATCH 08/28] mm, page_alloc: Convert alloc_flags to unsigned
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-9-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <571F51A7.3000300@suse.cz>
Date: Tue, 26 Apr 2016 13:31:51 +0200
MIME-Version: 1.0
In-Reply-To: <1460710760-32601-9-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 04/15/2016 10:59 AM, Mel Gorman wrote:
> alloc_flags is a bitmask of flags but it is signed which does not
> necessarily generate the best code depending on the compiler. Even
> without an impact, it makes more sense that this be unsigned.
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

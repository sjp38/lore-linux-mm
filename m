Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EFE03C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:58:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD9CD218AE
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 21:58:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD9CD218AE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E69D6B0003; Wed, 20 Mar 2019 17:58:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494AB6B0006; Wed, 20 Mar 2019 17:58:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3AA526B0007; Wed, 20 Mar 2019 17:58:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id ECE836B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 17:58:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v3so3929059pgk.9
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 14:58:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tLoGy0H8ICUu31snVAZ25iYHnHzblRMqhkpdGHi2Eo4=;
        b=NjCzLUVnGoo83ZuExe0qifP+Xl7g+38a8GVbePvagxkxJDDsy1tisw7xB1d9c5gqjx
         X+iV70pQPnR6bQsDWkUVtTLCYCF1GSVdXbjyjsorAVofMrWLvVH28mxVAtAASJrCrKiW
         9Y6lpn3iRlElgEjlp0hMi0WnHYuGnHt1SIX+64T9o38AlrDaz39IMbHkuepLjK1hPGTZ
         syNTPCIhF7nGTabkaNaF98Z7lsLZ+VSwrBkP5sRv/SLZhDg9FeDxXJwwCeyd/rQvdsyO
         D9A8QXpYjp8dlRJjEblmEvVsocAakDJ+WsXRimQIL2mKPln+fZFWXtYVQs3XcdY4aQHA
         22og==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWa/pednmel9CtnN64y+PxvmZgyjXf6esAjq8uRQ/piCZY2UGL7
	EZCPXfLA5RoGjWTGihU09C6b7EoH6jntF88LtNiWfdY7bXf0z7vdWXA5z3mZndNYEn1jnwzvu//
	0EysnWTyHlUFhXvWH4UP6xh7lN+zCJybrVEB04/F//2Wgr9/vFqF6bb3gWZy0ayORng==
X-Received: by 2002:a63:6fc4:: with SMTP id k187mr223978pgc.312.1553119108440;
        Wed, 20 Mar 2019 14:58:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo4c7rPsYZuQ5MNMtkbDhKdl1F1EuL7PugdMkmF5GpOs7srUlZQlQHzyCg5Rv2AnT9Fwo6
X-Received: by 2002:a63:6fc4:: with SMTP id k187mr223940pgc.312.1553119107632;
        Wed, 20 Mar 2019 14:58:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553119107; cv=none;
        d=google.com; s=arc-20160816;
        b=PIzPmYnDM0kt4Ws3PppJIpjt1p3XsSLPvEniHeSDgTmj/cH9wlUbHuUNjQ3KtG9AjX
         0QFfWyAbAclnchkyqCjhF3j+tk/wIrCfBp2JmyYUzWFHfRamIdDBQTrTB/gfeDVKRKiy
         0/hZGFITh7ZetbYntNAXn1+pRSd1n0ucH8JifA8CuDAeuymciKb2oYuEiKHOrjc9MpqR
         edEL8djcQtWweoOSuHY6LB/PtT9h9Q4EYF7WxAWW25PZlo88YEtFInAtMvbzlRwiPqB7
         Xdkj/UT5RNdUG9Vri2bCwpgUdEpwauxz1MplrX1DeBUwBPsC1cvZ/p08OJ3hmpUCE3MT
         kKmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=tLoGy0H8ICUu31snVAZ25iYHnHzblRMqhkpdGHi2Eo4=;
        b=VG/RWwKgwIFhecUzWrHH+w/gqCSv3klUp694/MwN7aDKJCr0Qch7r9ji1Yv/rYWmqf
         ZouvBTfOHDtgmVcJrNKj4m5NyfEzmvDYHx1ER12G6m81ymLiov70DPrG4vOq6kEE/zf+
         G1I4/LrJKn2b1sLg+uz2oVDNqq1ekC1NF6bb1VMyxWCUo8rnAMsQNldC3OiBA39OBfVq
         ToOZJnsyDJbzy7umo8KsAEU1SfHHs/bIdlvgmhUppBBxhxvhVB7BWFTnRzANTbyMesqp
         pL0H0FMnkMicIvV7lTmlddQ4siLUILOG8QhErBcmLfQJ4f77j9Y/N/kvUl6NBibKPARO
         /Thg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z3si2645541pgr.90.2019.03.20.14.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 14:58:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 24B566DB7;
	Wed, 20 Mar 2019 21:58:27 +0000 (UTC)
Date: Wed, 20 Mar 2019 14:58:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Qian Cai <cai@lca.pw>
Cc: mgorman@techsingularity.net, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [RESEND#2 PATCH] mm/compaction: fix an undefined behaviour
Message-Id: <20190320145826.9c647fe53bd999bbd2ee188d@linux-foundation.org>
In-Reply-To: <20190320203338.53367-1-cai@lca.pw>
References: <20190320203338.53367-1-cai@lca.pw>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Mar 2019 16:33:38 -0400 Qian Cai <cai@lca.pw> wrote:

> In a low-memory situation, cc->fast_search_fail can keep increasing as
> it is unable to find an available page to isolate in
> fast_isolate_freepages(). As the result, it could trigger an error
> below, so just compare with the maximum bits can be shifted first.
> 
> UBSAN: Undefined behaviour in mm/compaction.c:1160:30
> shift exponent 64 is too large for 64-bit type 'unsigned long'
> CPU: 131 PID: 1308 Comm: kcompactd1 Kdump: loaded Tainted: G
> W    L    5.0.0+ #17
> Call trace:
>  dump_backtrace+0x0/0x450
>  show_stack+0x20/0x2c
>  dump_stack+0xc8/0x14c
>  __ubsan_handle_shift_out_of_bounds+0x7e8/0x8c4
>  compaction_alloc+0x2344/0x2484
>  unmap_and_move+0xdc/0x1dbc
>  migrate_pages+0x274/0x1310
>  compact_zone+0x26ec/0x43bc
>  kcompactd+0x15b8/0x1a24
>  kthread+0x374/0x390
>  ret_from_fork+0x10/0x18
> 
> Fixes: 70b44595eafe ("mm, compaction: use free lists to quickly locate a migration source")
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Mel Gorman <mgorman@techsingularity.net>
> Signed-off-by: Qian Cai <cai@lca.pw>
> ---
>  mm/compaction.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index e1a08fc92353..0d1156578114 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1157,7 +1157,9 @@ static bool suitable_migration_target(struct compact_control *cc,
>  static inline unsigned int
>  freelist_scan_limit(struct compact_control *cc)
>  {
> -	return (COMPACT_CLUSTER_MAX >> cc->fast_search_fail) + 1;
> +	return (COMPACT_CLUSTER_MAX >>
> +		min((unsigned short)(BITS_PER_LONG - 1), cc->fast_search_fail))
> +		+ 1;
>  }

That's rather an eyesore.  How about

static inline unsigned int
freelist_scan_limit(struct compact_control *cc)
{
	unsigned short shift = BITS_PER_LONG - 1;

	return (COMPACT_CLUSTER_MAX >> min(shift, cc->fast_search_fail)) + 1;
}


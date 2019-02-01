Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9568C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 15:06:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFC9720855
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 15:06:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFC9720855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53FAF8E0003; Fri,  1 Feb 2019 10:06:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C7BA8E0001; Fri,  1 Feb 2019 10:06:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36C138E0003; Fri,  1 Feb 2019 10:06:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CD9028E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 10:06:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t2so2905332edb.22
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 07:06:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ejJEqGTeL0OHykvCEe/yGOAYrR6KxeUCTBncO9JamkI=;
        b=Mh9zMYIPAJDCMVJsg1vy+m9HOA/XzSecrXsC+jg7Hf5Jza3oUofNDXwsyLAG9yUXAH
         A7x18ZPjKqo1rp/Uqty50zWE2vS23VXHdGngyeEFzcWLVtYaFm/s0z7cMX8mTlVuRySl
         eyfu3LJGYtmlwpDT0wk+JQjJRDz3FTRqFDz6m8RwKqn/J+8NqDjwS19ZTEwc3bP96LKO
         RORKll90uDL7LRpROD0mplqJpFj5EG/Vw4x0gI1abk4lok7uLLPwHfzXY7QIHIVTtPo1
         lJp5cL2kPYIPUriEVjb5eLGhJuOKSmWbp+02Szcfo+mH+UNDXO0JiLQEmbgvjpEI0xlB
         lv1Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: AJcUukc8x/Hcv0lYTH0VQmplNAiVtMbqbfkcwgzw7GfKsQC4boIPSyre
	2/fXIgQm6DjxWfm8wC0YWvxBGE62vAxQm2Se2s7QxrA5zblSmBfVzh/biZdHQQoxeciumGf+dYd
	mIVKN83R6ojEygrVoPw+aldK6u+NUKooZ1VbLq8RI9FHvethtroD/QJmJNXQIQQVqow==
X-Received: by 2002:a17:906:4b4c:: with SMTP id j12mr34718546ejv.185.1549033577371;
        Fri, 01 Feb 2019 07:06:17 -0800 (PST)
X-Google-Smtp-Source: ALg8bN78xgxIFlrhxMdNuQRuDweyPycWIoi7Fk/srhKmiEeM6MIMEAzAZB+BBJTKMy5Tom3vw9aB
X-Received: by 2002:a17:906:4b4c:: with SMTP id j12mr34718478ejv.185.1549033576112;
        Fri, 01 Feb 2019 07:06:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549033576; cv=none;
        d=google.com; s=arc-20160816;
        b=hjrjzAvCyWIaj9T5PGhl1j8mUZAnOU8FzU9abjRpF6FhjWfhUJEsu9qwFpquA6XcXA
         Ih2N5lwAHH2jge017TASDeJvjEYJHzu4PapAVWwZOA0icqY0i9uuxPIDpQl+GUJ+ua2F
         wpaQfhZ8Ty8NVip+KRrzdde05FI+IkKt0S+Bj0dO3jQWDW8YH55dF2gBxsETKnMJEJOI
         FKGrnlPrXVnT0wSWYNH/4Fy6lvKOSbUlvRrY8wl9SKjZV5htg5xLamG1/Y2sWIoL7bTu
         Gt9hPkDLzoaj2YG6B8ScdU9Fww56qofteZwfNDVOMl7hiwbftwv5lC182SE9NVjIrrhj
         WYCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ejJEqGTeL0OHykvCEe/yGOAYrR6KxeUCTBncO9JamkI=;
        b=P3jHDY4Qi0LPUHKG59ERT1+MMYPx0btli72z/TjRWyrmyXHzyCi8m2s2GAtFIcfbZw
         bxKx2HsxqJeYfLdRCM8ecHYAtVvP/4GcqZbiV2HNe0L7yZ2iPMAn3j7lsJypnRyV1bTt
         JAOafWOyMNL955q3i2cu93/nAShN2TdHjwetbr5E6FdAvNdT6F+WBM3luYK5Zci+NHZo
         hr2mm15V8M4XrqD0PW5JV9wzd6KK6lEHjMxucWdRZzMCRjZ2cytp48GNK3rQm8OUWanf
         1fsp+ihTqyEYKemKsLMhWuWTJcoZ8ALnNrzVCRFWgUWZUT5V0eSSgEvCj/sT9BxeT/HU
         hCHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id h12si2993529ejd.48.2019.02.01.07.06.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 07:06:16 -0800 (PST)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) client-ip=46.22.139.17;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.17 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id A8CD31C2247
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 15:06:15 +0000 (GMT)
Received: (qmail 22173 invoked from network); 1 Feb 2019 15:06:15 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 1 Feb 2019 15:06:15 -0000
Date: Fri, 1 Feb 2019 15:06:14 +0000
From: Mel Gorman <mgorman@techsingularity.net>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 09/22] mm, compaction: Use free lists to quickly locate a
 migration source
Message-ID: <20190201150614.GJ9565@techsingularity.net>
References: <20190118175136.31341-1-mgorman@techsingularity.net>
 <20190118175136.31341-10-mgorman@techsingularity.net>
 <4a6ae9fc-a52b-4300-0edb-a0f4169c314a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4a6ae9fc-a52b-4300-0edb-a0f4169c314a@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 02:55:01PM +0100, Vlastimil Babka wrote:
> > +
> > +				/*
> > +				 * Avoid if skipped recently. Ideally it would
> > +				 * move to the tail but even safe iteration of
> > +				 * the list assumes an entry is deleted, not
> > +				 * reordered.
> > +				 */
> > +				if (get_pageblock_skip(freepage)) {
> > +					if (list_is_last(freelist, &freepage->lru))
> > +						break;
> > +
> > +					continue;
> > +				}
> > +
> > +				/* Reorder to so a future search skips recent pages */
> > +				move_freelist_tail(freelist, freepage);
> > +
> > +				pfn = pageblock_start_pfn(free_pfn);
> > +				cc->fast_search_fail = 0;
> > +				set_pageblock_skip(freepage);
> > +				break;
> > +			}
> > +
> > +			if (nr_scanned >= limit) {
> > +				cc->fast_search_fail++;
> > +				move_freelist_tail(freelist, freepage);
> > +				break;
> > +			}
> > +		}
> > +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> > +	}
> > +
> > +	cc->total_migrate_scanned += nr_scanned;
> > +
> > +	/*
> > +	 * If fast scanning failed then use a cached entry for a page block
> > +	 * that had free pages as the basis for starting a linear scan.
> > +	 */
> > +	if (pfn == cc->migrate_pfn)
> > +		reinit_migrate_pfn(cc);
> 
> This will set cc->migrate_pfn to the lowest pfn encountered, yet return
> pfn initialized by original cc->migrate_pfn.
> AFAICS isolate_migratepages() will use the returned pfn for the linear
> scan and then overwrite cc->migrate_pfn with wherever it advanced from
> there. So whatever we stored here into cc->migrate_pfn will never get
> actually used, except when isolate_migratepages() returns with
> ISOLATED_ABORT.
> So maybe the infinite kcompactd loop is linked to ISOLATED_ABORT?
> 

I'm not entirely sure it would fix the infinite loop. I suspect that is
going to be a boundary conditions where the two scanners are close but
do not meet if it still exists after the batch of fixes. However, you're
right that this code is problematic. I'll write a fix, test it and post
it if it's ok.

Well spotted!

-- 
Mel Gorman
SUSE Labs


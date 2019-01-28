Return-Path: <SRS0=rmuZ=QE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B94CEC282CD
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:56:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F5172175B
	for <linux-mm@archiver.kernel.org>; Mon, 28 Jan 2019 22:56:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F5172175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30C728E0003; Mon, 28 Jan 2019 17:56:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BCA18E0001; Mon, 28 Jan 2019 17:56:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D47E8E0003; Mon, 28 Jan 2019 17:56:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D37DE8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 17:56:19 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id t2so15228243pfj.15
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 14:56:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W30ULAGcSChoWcQwa9f9Z/5sKM38IBC3Zbc5mQ/sLCM=;
        b=b1QqUrbe8m43OUXj7qcaPTvRd4p9cqTOyMwLnRsXxeWe82TIuzngxaUyVzIVl+H8dx
         +fOGHHgVkQ8GBoE5YaGiYNAJHN6QVTXw3PfAqEDWS/pOL/Ow+eBnRUz1lKZBVhlGRY0c
         E7RYUfXqo9W/qhh61ioAtsP1/VnQbhbeQGdiJOe5iouVLOkSg3SqZNAHUSoAgLdmQn+W
         vbUq5XvRIRKRk2TMw0mbLq5YvAA2uVb54Nv8X8aYpWaO4WfD+6+LKuasCKUBt3v+0jaP
         tggNyinh0nh6gc4isZY6pStxLQR/N8iedCDHGgPrN78H/T8PV5TKxACRA2itT1qTPE8H
         Ni/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: AJcUukffRcW55SHg8trPiRBnr+cnthw/RdGBwcXTtz1LhG6VtLGdJkCR
	LVSGbHygBYJDaTJFF3JD0ez3ICuux700pm+cPNnV6b1W9+rsHOi+DS3L0nC1MyYDgW7/wt5RqRv
	C4tAQOt9lmg/WJckz0pfsaKaB0vLTIIDVjm07ga1ByR3pYdpFNqX2h9uhoFMk2wo75w==
X-Received: by 2002:a63:2905:: with SMTP id p5mr21745262pgp.178.1548716179518;
        Mon, 28 Jan 2019 14:56:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN63e6nxsN2wd6I2XpYvW7uq4DU+aKbu/VyfsEN3WLccu1d73iJy1BUMCYAh5otl3cj8f/Hh
X-Received: by 2002:a63:2905:: with SMTP id p5mr21745244pgp.178.1548716178913;
        Mon, 28 Jan 2019 14:56:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548716178; cv=none;
        d=google.com; s=arc-20160816;
        b=eStQgK0J9AIBnMOaX+B1nOvO07xw4l4lptjQbudiU/LvJMGjxq6YeSP+X7YQeyfbqZ
         X6eFPInajS9VPdZzRI9PPPQn6i5iV8xZUmbkF+4igsp0n43f4yo4gTq8u1fjoFEr1KVl
         i0VoqKGIKjv1W3tazihjyJKk+4lllWKWnpf/+NdcMizBhcUYulq+n2SFSZp3sOYSVGpl
         ruQdfPI6ZMZO5XyWUhlszFgo0+UmsRNr/ynSBMOfnnib/RKrUkJ1eGFPuol2NczrbfWt
         x22PJD5K2VGaGCIiOIgbejwUSvhTm314sdLTyrnA9xIg/qeypsrpHLu8Bl6Y/nB8V+dX
         /bsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:to:from:date;
        bh=W30ULAGcSChoWcQwa9f9Z/5sKM38IBC3Zbc5mQ/sLCM=;
        b=C660gQ0g0PPNlf+Ja0eiqMZB8vosdAu1KqgfuS2ZstHRGzVgi4b7mJrEwPTV1QhvU8
         YyPQOEds1hg21/siPkY0D4iy2fZXfmrI8RWIvleDDG3mLLmR2ok35fo6aK+0LUHZfL1T
         ZGfAeEeY0J4fyvD2/TPdblYUEtf/OtAyW/F9WoRqlRYBHUBSF4lXyleFsvII6/yTkLOL
         3TB6rUoj/DqoSsci7MdTAFR2kkS1T7qWZB48F3Vu6dCLjrgXzLxAr5plpHaFP1Z4vjSq
         iQ2Oa79nIb8emxhRMUUV2FXnkQt6sFwmIBNmXpqpVXFpiaVP5JCZLmj+tqi54IjyUy/t
         VsXw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m188si15900035pfb.266.2019.01.28.14.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 14:56:18 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 72A7619DB;
	Mon, 28 Jan 2019 22:56:18 +0000 (UTC)
Date: Mon, 28 Jan 2019 14:56:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Oscar Salvador <osalvador@suse.de>, David Hildenbrand
 <david@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mhocko@suse.com
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
Message-Id: <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
In-Reply-To: <20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
References: <20190122154407.18417-1-osalvador@suse.de>
	<5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
	<20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
	<20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 14:53:09 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 25 Jan 2019 08:58:33 +0100 Oscar Salvador <osalvador@suse.de> wrote:
> 
> > On Wed, Jan 23, 2019 at 11:33:56AM +0100, David Hildenbrand wrote:
> > > If you use {} for the else case, please also do so for the if case.
> > 
> > Diff on top:
> > 
> > diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> > index 25aee4f04a72..d5810e522b72 100644
> > --- a/mm/memory_hotplug.c
> > +++ b/mm/memory_hotplug.c
> > @@ -1338,9 +1338,9 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> >  				struct page *head = compound_head(page);
> >  
> >  				if (hugepage_migration_supported(page_hstate(head)) &&
> > -				    page_huge_active(head))
> > +				    page_huge_active(head)) {
> >  					return pfn;
> > -				else {
> > +				} else {
> >  					unsigned long skip;
> >  
> >  					skip = (1 << compound_order(head)) - (page - head);
> > 
> 
> The indenting is getting a bit deep also, so how about this?
> 
> static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> {
> 	unsigned long pfn;
> 
> 	for (pfn = start; pfn < end; pfn++) {
> 		struct page *page, *head;
> 	
> 		if (!pfn_valid(pfn))
> 			continue;
> 		page = pfn_to_page(pfn);
> 		if (PageLRU(page))
> 			return pfn;
> 		if (__PageMovable(page))
> 			return pfn;
> 
> 		if (!PageHuge(page))
> 			continue;
> 		head = compound_head(page);
> 		if (hugepage_migration_supported(page_hstate(head)) &&
> 		    page_huge_active(head)) {
> 			return pfn;

checkpatch pointed out that else-after-return isn't needed so we can do

static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
{
	unsigned long pfn;

	for (pfn = start; pfn < end; pfn++) {
		struct page *page, *head;
		unsigned long skip;

		if (!pfn_valid(pfn))
			continue;
		page = pfn_to_page(pfn);
		if (PageLRU(page))
			return pfn;
		if (__PageMovable(page))
			return pfn;

		if (!PageHuge(page))
			continue;
		head = compound_head(page);
		if (hugepage_migration_supported(page_hstate(head)) &&
		    page_huge_active(head))
			return pfn;
		skip = (1 << compound_order(head)) - (page - head);
		pfn += skip - 1;
	}
	return 0;
}

--- a/mm/memory_hotplug.c~mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages-fix
+++ a/mm/memory_hotplug.c
@@ -1305,28 +1305,27 @@ int test_pages_in_a_zone(unsigned long s
 static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
 {
 	unsigned long pfn;
-	struct page *page;
+
 	for (pfn = start; pfn < end; pfn++) {
-		if (pfn_valid(pfn)) {
-			page = pfn_to_page(pfn);
-			if (PageLRU(page))
-				return pfn;
-			if (__PageMovable(page))
-				return pfn;
-			if (PageHuge(page)) {
-				struct page *head = compound_head(page);
+		struct page *page, *head;
+		unsigned long skip;
 
-				if (hugepage_migration_supported(page_hstate(head)) &&
-				    page_huge_active(head))
-					return pfn;
-				else {
-					unsigned long skip;
+		if (!pfn_valid(pfn))
+			continue;
+		page = pfn_to_page(pfn);
+		if (PageLRU(page))
+			return pfn;
+		if (__PageMovable(page))
+			return pfn;
 
-					skip = (1 << compound_order(head)) - (page - head);
-					pfn += skip - 1;
-				}
-			}
-		}
+		if (!PageHuge(page))
+			continue;
+		head = compound_head(page);
+		if (hugepage_migration_supported(page_hstate(head)) &&
+		    page_huge_active(head))
+			return pfn;
+		skip = (1 << compound_order(head)) - (page - head);
+		pfn += skip - 1;
 	}
 	return 0;
 }
_


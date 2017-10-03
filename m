Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CC4646B0038
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 04:51:04 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id n1so12932598pgt.4
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 01:51:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si9884824plb.807.2017.10.03.01.51.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 03 Oct 2017 01:51:03 -0700 (PDT)
Date: Tue, 3 Oct 2017 10:51:01 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 12/15] mm: Add variant of pagevec_lookup_range_tag()
 taking number of pages
Message-ID: <20171003085101.GG11879@quack2.suse.cz>
References: <20170927160334.29513-1-jack@suse.cz>
 <20170927160334.29513-13-jack@suse.cz>
 <91bd5e36-3f73-c770-9555-bff47f74f49a@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <91bd5e36-3f73-c770-9555-bff47f74f49a@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Fri 29-09-17 17:45:33, Daniel Jordan wrote:
> On 09/27/2017 12:03 PM, Jan Kara wrote:
> >+unsigned pagevec_lookup_range_nr_tag(struct pagevec *pvec,
> >+		struct address_space *mapping, pgoff_t *index, pgoff_t end,
> >+		int tag, unsigned max_pages)
> >+{
> >+	pvec->nr = find_get_pages_range_tag(mapping, index, end, tag,
> >+		min_t(unsigned int, max_pages, PAGEVEC_SIZE), pvec->pages);
> >+	return pagevec_count(pvec);
> >+}
> >+EXPORT_SYMBOL(pagevec_lookup_range_tag);
> 
> The EXPORT_SYMBOL should be pagevec_lookup_range_nr_tag instead of
> pagevec_lookup_range_tag.

Ah, good catch. Fixed. Thanks!

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

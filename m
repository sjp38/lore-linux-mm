Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 198EC8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 06:46:49 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 124so15241644ybb.9
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 03:46:49 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id f4si34248794ywa.160.2019.01.02.03.46.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Jan 2019 03:46:48 -0800 (PST)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] mm: Introduce page_size()
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190102031414.GG6310@bombadil.infradead.org>
Date: Wed, 2 Jan 2019 04:46:27 -0700
Content-Transfer-Encoding: 7bit
Message-Id: <0952D432-F520-4830-A1DE-479DFAD283E7@oracle.com>
References: <20181231134223.20765-1-willy@infradead.org>
 <87y385awg6.fsf@linux.ibm.com> <20190101063031.GD6310@bombadil.infradead.org>
 <87lg447knf.fsf@linux.ibm.com> <20190102031414.GG6310@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

It's tricky, simply because if someone doesn't know the size of their
current page, they would generally want to know what size the current
page is mapped as, based upon what is currently extant within that address
space.

So for example, assuming read-only pages, if an as has a PMD-sized THP
mapped, it seems as if page_size() for any address within that PMD
address range should return the PMD size as compound page head/tail is
an implementation issue, not a VM one per se.

On the other hand, if another as has a portion of the physical space
the THP occupies mapped as a PAGESIZE page, a page_size() for and address
within that range should return PAGESIZE.

Forgive me if I'm being impossibly naive here.

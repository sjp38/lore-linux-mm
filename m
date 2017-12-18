Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0F26C6B0033
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 16:44:58 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id w22so11469889pge.10
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 13:44:58 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id g59si10003223plb.658.2017.12.18.13.44.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Dec 2017 13:44:57 -0800 (PST)
Date: Mon, 18 Dec 2017 13:44:55 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/8] mm: De-indent struct page
Message-ID: <20171218214455.GA31673@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-3-willy@infradead.org>
 <20171218153652.GC3876@dhcp22.suse.cz>
 <20171218161902.GA688@bombadil.infradead.org>
 <20171218204935.GU16951@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171218204935.GU16951@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Mon, Dec 18, 2017 at 09:49:35PM +0100, Michal Hocko wrote:
> Excelent! Could you add the later one to the changelog please? With
> that
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> I will go over the rest of the series tomorrow.

Thanks!  I've added Kirill's and Randy's Acks/Reviews too.  Christoph,
any chance you'd be able to provide an ack on this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

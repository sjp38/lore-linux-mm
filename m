Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 933CA6B0038
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 10:55:36 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id o17so9697007pli.7
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 07:55:36 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f1si12063636pgq.100.2017.12.20.07.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 07:55:35 -0800 (PST)
Date: Wed, 20 Dec 2017 07:55:34 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 0/8] Restructure struct page
Message-ID: <20171220155534.GA1840@bombadil.infradead.org>
References: <20171220155256.9841-1-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20171220155256.9841-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linuxfoundation.org, Matthew Wilcox <mawilcox@microsoft.com>

On Wed, Dec 20, 2017 at 07:52:48AM -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This series does not attempt any grand restructuring as I proposed last
> week.  Instead, it cures the worst of the indentitis, fixes the
> documentation and reduces the ifdeffery.  The only layout change is
> compound_dtor and compound_order are each reduced to one byte.  At
> least, that's my intent.  

My apologies.  I typod my git send-email and resent v1, instead of sending v2.

"A computer lets you make more mistakes faster than any other invention
with the possible exceptions of handguns and Tequila." a?? Mitch Ratcliffe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 517E88E0038
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 16:26:52 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id m16so2817846pgd.0
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 13:26:52 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id x9si4672112pll.131.2019.01.08.13.26.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 13:26:51 -0800 (PST)
Date: Tue, 8 Jan 2019 13:26:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Remove redundant test from find_get_pages_contig
Message-Id: <20190108132649.8f25386d966f04b0bccd6d77@linux-foundation.org>
In-Reply-To: <20190108202635.GE6310@bombadil.infradead.org>
References: <20190107200224.13260-1-willy@infradead.org>
	<20190107143319.c74593a70c86441b80e7cccc@linux-foundation.org>
	<20190107223935.GC6310@bombadil.infradead.org>
	<20190107150904.09e56f51acaf417ed21f13a3@linux-foundation.org>
	<20190108202635.GE6310@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 8 Jan 2019 12:26:35 -0800 Matthew Wilcox <willy@infradead.org> wrote:

> > Would it be excessively cautious to put a WARN_ON_ONCE() in there for a
> > while?
> 
> I think it would ... it'd get in the way of a subsequent patch to store
> only head pages in the page cache.

OK, shall grab.  Perhaps the changelog could gain a few words
explaining the history, etc.

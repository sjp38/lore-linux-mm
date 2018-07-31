Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D527D6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 20:45:12 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id w14-v6so3868898pfn.13
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 17:45:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g2-v6si12200355pgg.83.2018.07.30.17.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Jul 2018 17:45:11 -0700 (PDT)
Date: Mon, 30 Jul 2018 17:45:04 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
Message-ID: <20180731004504.GB19692@bombadil.infradead.org>
References: <20180724210923.GA20168@bombadil.infradead.org>
 <20180725023728.44630-1-cannonmatthews@google.com>
 <20180730162926.GD11890@nazgul.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730162926.GD11890@nazgul.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Cannon Matthews <cannonmatthews@google.com>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>

On Mon, Jul 30, 2018 at 06:29:27PM +0200, Borislav Petkov wrote:
> > +EXPORT_SYMBOL(__clear_page_nt)
> 
> EXPORT_SYMBOL_GPL like the other functions in that file.

Actually, __clear_page_nt doesn't need to be exported at all for this
patch set; it's not invoked from a module.

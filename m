Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6E96B02C3
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:38:57 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id n21-v6so4805615plp.9
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:38:57 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k26-v6si10857933pfk.199.2018.07.25.07.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 25 Jul 2018 07:38:56 -0700 (PDT)
Date: Wed, 25 Jul 2018 07:38:50 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] RFC: clear 1G pages with streaming stores on x86
Message-ID: <20180725143850.GA2886@bombadil.infradead.org>
References: <20180724210923.GA20168@bombadil.infradead.org>
 <20180725023728.44630-1-cannonmatthews@google.com>
 <DF4PR8401MB11806B9D2A7FE04B1F5ECBF8AB540@DF4PR8401MB1180.NAMPRD84.PROD.OUTLOOK.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <DF4PR8401MB11806B9D2A7FE04B1F5ECBF8AB540@DF4PR8401MB1180.NAMPRD84.PROD.OUTLOOK.COM>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Elliott, Robert (Persistent Memory)" <elliott@hpe.com>
Cc: Cannon Matthews <cannonmatthews@google.com>, Michal Hocko <mhocko@kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andres Lagar-Cavilla <andreslc@google.com>, Salman Qazi <sqazi@google.com>, Paul Turner <pjt@google.com>, David Matlack <dmatlack@google.com>, Peter Feiner <pfeiner@google.com>, Alain Trinh <nullptr@google.com>

On Wed, Jul 25, 2018 at 05:02:46AM +0000, Elliott, Robert (Persistent Memory) wrote:
> Even with that, one CPU core won't saturate the memory bus; multiple
> CPU cores (preferably on the same NUMA node as the memory) need to
> share the work.

It's probably OK to not saturate the memory bus; it'd be nice if other
cores were allowed to get work done.  If your workload is single-threaded,
you're right, of course, but who has a single-threaded workload these
days?!

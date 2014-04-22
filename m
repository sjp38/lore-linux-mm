Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4BB9B6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 11:19:51 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id 63so2168653qgz.9
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 08:19:51 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id j94si2126714qge.138.2014.04.22.08.19.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Apr 2014 08:19:45 -0700 (PDT)
Date: Tue, 22 Apr 2014 08:19:39 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Export kmem tracepoints for use by kernel modules
Message-ID: <20140422151939.GA19369@infradead.org>
References: <20140422142244.GA21121@dreric01-Precision-T1600>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140422142244.GA21121@dreric01-Precision-T1600>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Drew Richardson <drew.richardson@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michel Lespinasse <walken@google.com>, Mikulas Patocka <mpatocka@redhat.com>, William Roberts <bill.c.roberts@gmail.com>, Gideon Israel Dsouza <gidisrael@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pawel Moll <pawel.moll@arm.com>

On Tue, Apr 22, 2014 at 07:22:45AM -0700, Drew Richardson wrote:
> After commit de7b2973903c6cc50b31ee5682a69b2219b9919d ("tracepoint:
> Use struct pointer instead of name hash for reg/unreg tracepoints"),
> any tracepoints used in a kernel module must be exported.

But none of them are used by any in-tree module, so this isn't relevant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

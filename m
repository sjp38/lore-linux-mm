Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 50CC76B0038
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 03:31:03 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x7so7241442pfa.19
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 00:31:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 125si219880pff.568.2017.10.13.00.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 00:31:02 -0700 (PDT)
Date: Fri, 13 Oct 2017 00:31:01 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v6 3/4] cramfs: add mmap support
Message-ID: <20171013073101.GJ9105@infradead.org>
References: <20171012061613.28705-1-nicolas.pitre@linaro.org>
 <20171012061613.28705-4-nicolas.pitre@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171012061613.28705-4-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

As said before I'm no big fan of all the debug chatter, but the rest
looks fine, so:

Reviewed-by: Christoph Hellwig <hch@lst.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

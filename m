Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9E56B025E
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 04:30:54 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p5so7227398pgn.7
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 01:30:54 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id l12si5928653plc.384.2017.10.01.01.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 01:30:53 -0700 (PDT)
Date: Sun, 1 Oct 2017 01:30:52 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH v4 4/5] cramfs: add mmap support
Message-ID: <20171001083052.GB17116@infradead.org>
References: <20170927233224.31676-1-nicolas.pitre@linaro.org>
 <20170927233224.31676-5-nicolas.pitre@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927233224.31676-5-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

up_read(&mm->mmap_sem) in the fault path is a still a complete
no-go,

NAK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

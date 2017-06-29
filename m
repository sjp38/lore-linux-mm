Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 96D836B0292
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 07:19:42 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k2so6771298ioe.4
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 04:19:42 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id t195si868326ita.14.2017.06.29.04.19.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 04:19:41 -0700 (PDT)
Date: Thu, 29 Jun 2017 14:19:16 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [bug report] percpu: add tracepoint support for percpu memory
Message-ID: <20170629110954.uz6he7x25bg4n3pp@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dennisz@fb.com
Cc: linux-mm@kvack.org

Hello Dennis Zhou,

This is a semi-automatic email about new static checker warnings.

The patch df95e795a722: "percpu: add tracepoint support for percpu
memory" from Jun 19, 2017, leads to the following Smatch complaint:

    mm/percpu-km.c:88 pcpu_destroy_chunk()
    warn: variable dereferenced before check 'chunk' (see line 86)

mm/percpu-km.c
    85		pcpu_stats_chunk_dealloc();
    86		trace_percpu_destroy_chunk(chunk->base_addr);
                                           ^^^^^^^^^^^^^^^^
There should probably be a NULL check here?

    87	
    88		if (chunk && chunk->data)
    89			__free_pages(chunk->data, order_base_2(nr_pages));
    90		pcpu_free_chunk(chunk);

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

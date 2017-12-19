Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69DDD6B0253
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 09:58:22 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id w189so5157903iof.18
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 06:58:22 -0800 (PST)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id q143si10121031iod.78.2017.12.19.06.58.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 06:58:21 -0800 (PST)
Date: Tue, 19 Dec 2017 08:58:20 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 1/8] mm: Align struct page more aesthetically
In-Reply-To: <20171216164425.8703-2-willy@infradead.org>
Message-ID: <alpine.DEB.2.20.1712190857580.16727@nuc-kabylake>
References: <20171216164425.8703-1-willy@infradead.org> <20171216164425.8703-2-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>


Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

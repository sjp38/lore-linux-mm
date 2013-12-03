Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id CAD9C6B0037
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 10:24:10 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so5652024qaq.15
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 07:24:10 -0800 (PST)
Received: from a9-113.smtp-out.amazonses.com (a9-113.smtp-out.amazonses.com. [54.240.9.113])
        by mx.google.com with ESMTP id s9si35902091qas.99.2013.12.03.07.24.09
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 07:24:10 -0800 (PST)
Date: Tue, 3 Dec 2013 15:24:09 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 4/5] slab: introduce byte sized index for the freelist
 of a slab
In-Reply-To: <20131203022539.GF31168@lge.com>
Message-ID: <00000142b90f2d77-5ef1595b-9e59-4985-99a2-712699bb252e-000000@email.amazonses.com>
References: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com> <1385974183-31423-5-git-send-email-iamjoonsoo.kim@lge.com> <20131203022539.GF31168@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> Can I get your ACK for this patch?

Sure.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

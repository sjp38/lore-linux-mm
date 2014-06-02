Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8909E6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 02:43:17 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id w8so2080314qac.19
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 23:43:17 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id z2si16615292qai.56.2014.06.01.23.43.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Jun 2014 23:43:12 -0700 (PDT)
Date: Sun, 1 Jun 2014 23:42:26 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/3] mm: introduce fincore()
Message-ID: <20140602064226.GA31675@infradead.org>
References: <20140521193336.5df90456.akpm@linux-foundation.org>
 <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org

Please also provide a man page for the system call.

I'm also very unhappy about the crazy different interpretation of the
return value depending on flags, which probably becomes more obvious if
you try to document it.

That being said I think fincore is useful, but why not stick to the
same simple interface as mincore?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A0F336B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 09:38:43 -0400 (EDT)
Received: by mail-wi0-f177.google.com with SMTP id ho1so1007204wib.10
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 06:38:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e4si2863242wij.16.2014.07.08.06.38.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jul 2014 06:38:42 -0700 (PDT)
Date: Tue, 8 Jul 2014 09:27:55 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 0/3] mm: introduce fincore() v3
Message-ID: <20140708132755.GA24698@nhori>
References: <1404756006-23794-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140708121618.GA2554@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140708121618.GA2554@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, Jul 08, 2014 at 05:16:18AM -0700, Christoph Hellwig wrote:
> Still a hard NAK for exposing page flags in a syscall ABI.  These are
> way to volatile to go into an application interface.

Is there any specific reason that exporting via syscall ABI is more
volatile than exporting via procfs as /proc/kpageflags alreadly does?

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

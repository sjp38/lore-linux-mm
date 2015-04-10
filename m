Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7E21C6B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 00:20:37 -0400 (EDT)
Received: by paboj16 with SMTP id oj16so9493003pab.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 21:20:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 4si1170730pdx.19.2015.04.09.21.20.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Apr 2015 21:20:36 -0700 (PDT)
Date: Thu, 9 Apr 2015 21:24:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: show free pages per each migrate type
Message-Id: <20150409212441.a64c3fe0.akpm@linux-foundation.org>
In-Reply-To: <COL130-W536B434DEADC19798C2A9FBAFA0@phx.gbl>
References: <BLU436-SMTP78227860F3E4FAF236A85CBAFB0@phx.gbl>
	<20150409134701.5903cb5217f5742bbacc73da@linux-foundation.org>
	<COL130-W536B434DEADC19798C2A9FBAFA0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ZhangNeil <neilzhang1123@hotmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, 10 Apr 2015 04:16:15 +0000 ZhangNeil <neilzhang1123@hotmail.com> wrote:

> > I think we can eliminate nr_free[][]:
> 
> what about make it as global__variable?

That isn't as good - it permanently consumes memory and really requires
new locking to protect the array from concurrent callers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 27D696B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 17:31:38 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so1509563pdj.6
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 14:31:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id e1si45999690pdi.234.2014.12.05.14.31.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Dec 2014 14:31:36 -0800 (PST)
Date: Fri, 5 Dec 2014 14:31:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
Message-Id: <20141205143134.37139da2208c654a0d3cd942@linux-foundation.org>
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103E688B313EE@CNBJMBX05.corpusers.net>
	<CALYGNiOuBKz8shHSrFCp0BT5AV6XkNOCHj+LJedQQ-2YdZtM7w@mail.gmail.com>
	<35FD53F367049845BC99AC72306C23D103E688B313F2@CNBJMBX05.corpusers.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Konstantin Khlebnikov' <koct9i@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>

On Fri, 5 Dec 2014 18:22:33 +0800 "Wang, Yalin" <Yalin.Wang@sonymobile.com> wrote:

> > -----Original Message-----
> > From: Konstantin Khlebnikov [mailto:koct9i@gmail.com]
> > Sent: Friday, December 05, 2014 5:21 PM
> > To: Wang, Yalin
> > Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; linux-arm-
> > kernel@lists.infradead.org; akpm@linux-foundation.org; n-
> > horiguchi@ah.jp.nec.com
> > Subject: Re: [RFC] mm:add KPF_ZERO_PAGE flag for /proc/kpageflags
> > 
> > On Fri, Dec 5, 2014 at 11:57 AM, Wang, Yalin <Yalin.Wang@sonymobile.com>
> > wrote:
> > > This patch add KPF_ZERO_PAGE flag for zero_page, so that userspace
> > > process can notice zero_page from /proc/kpageflags, and then do memory
> > > analysis more accurately.
> > 
> > It would be nice to mark also huge_zero_page. See (completely
> > untested) patch in attachment.
> > 
> Got it,
> Thanks for your patch.

Documentation/vm/pagemap.txt will need updating please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

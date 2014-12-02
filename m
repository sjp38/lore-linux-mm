Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3A06B006E
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 06:30:21 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id l18so16648909wgh.30
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 03:30:20 -0800 (PST)
Received: from jenni2.inet.fi (mta-out1.inet.fi. [62.71.2.227])
        by mx.google.com with ESMTP id e3si35694581wix.69.2014.12.02.03.30.18
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 03:30:18 -0800 (PST)
Date: Tue, 2 Dec 2014 13:30:14 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC V2] mm:add zero_page _mapcount when mapped into user space
Message-ID: <20141202113014.GA22683@node.dhcp.inet.fi>
References: <35FD53F367049845BC99AC72306C23D103E688B313E0@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D103E688B313E0@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

On Tue, Dec 02, 2014 at 05:27:36PM +0800, Wang, Yalin wrote:
> This patch add/dec zero_page's _mapcount to make sure
> the mapcount is correct for zero_page,
> so that when read from /proc/kpagecount, zero_page's
> mapcount is also correct, userspace process like procrank can
> calculate PSS correctly.

I don't have specific code path to point to, but I would expect zero page
with non-zero mapcount would cause a problem with rmap.

How do you test the change?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

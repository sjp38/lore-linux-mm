Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 61E3A6B006C
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 10:28:58 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id i57so1481211yha.7
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 07:28:58 -0800 (PST)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id r41si2996488yho.69.2015.01.08.07.28.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 Jan 2015 07:28:57 -0800 (PST)
From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 0/2] mm: infrastructure for correctly handling foreign pages on Xen
Date: Thu, 8 Jan 2015 15:28:42 +0000
Message-ID: <1420730924-22811-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

These two patches are the common parts of a larger Xen series[1]
fixing several long-standing bugs the handling of foreign[2] pages in
Xen guests.

The first patch is required to fix get_user_pages[_fast]() with
userspace space mappings of such foreign pages.  Basically, pte_page()
doesn't work so an alternate mechanism is needed to get the page from
a VMA and address.  By requiring mappings needing this method are
'special' this should not have an impact on the common use cases.

The second patch isn't essential but helps with readability of the
resulting user of the page flag.

For further background reading see:

  http://xenbits.xen.org/people/dvrabel/grant-improvements-C.pdf

David

[1] http://lists.xen.org/archives/html/xen-devel/2015-01/msg00326.html

[2] Another guest's page temporarily granted to this guest.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5FB6B0055
	for <linux-mm@kvack.org>; Tue, 15 Apr 2014 14:47:21 -0400 (EDT)
Received: by mail-yh0-f42.google.com with SMTP id t59so9804038yho.15
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 11:47:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x25si6571322yhk.204.2014.04.15.11.47.20
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 11:47:20 -0700 (PDT)
Date: Tue, 15 Apr 2014 14:47:12 -0400
From: Dave Jones <davej@redhat.com>
Subject: [3.15-rc1] return of bad rss-counter..
Message-ID: <20140415184712.GA24507@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

I hoped we'd seen the last of this, but aparently not..

BUG: Bad rss-counter state mm:ffff88023fc73c00 idx:0 val:5 (Not tainted)

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

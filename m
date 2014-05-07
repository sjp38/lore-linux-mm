Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id E6F9B6B0037
	for <linux-mm@kvack.org>; Wed,  7 May 2014 16:55:47 -0400 (EDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so8239070igq.16
        for <linux-mm@kvack.org>; Wed, 07 May 2014 13:55:47 -0700 (PDT)
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2001:4f8:3:36:211:85ff:fe63:a549])
        by mx.google.com with ESMTP id sd1si507051igb.27.2014.05.07.13.55.47
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 13:55:47 -0700 (PDT)
Date: Wed, 07 May 2014 16:55:44 -0400 (EDT)
Message-Id: <20140507.165544.265980659606200471.davem@davemloft.net>
Subject: Re: [PATCH] mm, thp: close race between mremap() and
 split_huge_page()
From: David Miller <davem@davemloft.net>
In-Reply-To: <20140506084333.GA5575@node.dhcp.inet.fi>
References: <1399328011-15317-1-git-send-email-kirill.shutemov@linux.intel.com>
	<20140506084333.GA5575@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, riel@redhat.com, walken@google.com, davej@redhat.com, stable@vger.kernel.org

From: "Kirill A. Shutemov" <kirill@shutemov.name>
Date: Tue, 6 May 2014 11:43:33 +0300

> It took a night but I was able to trigger crash which this patch fixes.

I love test cases like this.

Can we start collecting THP stressers and bug reproducers like this
under tools/testing/selftests/thp or similar?

I find that I'm constantly writing my own THP test cases or copying
the ones from the LTP tree and adjusting them to meet my needs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

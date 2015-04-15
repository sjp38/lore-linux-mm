Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C01AA6B0038
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 04:45:41 -0400 (EDT)
Received: by wiax7 with SMTP id x7so106652593wia.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 01:45:41 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id uw5si6874105wjc.49.2015.04.15.01.45.39
        for <linux-mm@kvack.org>;
        Wed, 15 Apr 2015 01:45:40 -0700 (PDT)
Date: Wed, 15 Apr 2015 11:45:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 00/11] mm: debug: formatting memory management structs
Message-ID: <20150415084536.GA27510@node.dhcp.inet.fi>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Apr 14, 2015 at 04:56:22PM -0400, Sasha Levin wrote:
> This patch series adds knowledge about various memory management structures
> to the standard print functions.
> 
> In essence, it allows us to easily print those structures:
> 
> 	printk("%pZp %pZm %pZv", page, mm, vma);

Notably, you don't have \n in your format line. And it brings question how
well dump_page() and friends fit printk-like interface. dump_page()
produces multi-line print out.
Is it something printk() users would expect?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

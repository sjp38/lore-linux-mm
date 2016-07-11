Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CC6D6B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 16:25:52 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p64so199742232pfb.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 13:25:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id q3si1605144pai.277.2016.07.11.13.25.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 13:25:51 -0700 (PDT)
Date: Mon, 11 Jul 2016 13:25:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] kexec: add a pmd huge entry condition during the
 page table
Message-Id: <20160711132550.75728ddb05317565ef7724d6@linux-foundation.org>
In-Reply-To: <1468218961-11018-2-git-send-email-zhongjiang@huawei.com>
References: <1468218961-11018-1-git-send-email-zhongjiang@huawei.com>
	<1468218961-11018-2-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 11 Jul 2016 14:36:01 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> when image is loaded into kernel, we need set up page table for it.
> and all valid pfn also set up new mapping. it will set up a pmd huge
> entry if pud_present is true.  relocate_kernel points to code segment
> can locate in the pmd huge entry in init_transtion_pgtable. therefore,
> we need to take the situation into account.

Sorry, I just don't understand this changelog.  The second sentence is
particularly hard.

So can you please have another attempt at preparing the changelog text?
The resend the patches and this time be sure to Cc the kexec
maintainers.  I suggest this list:

Cc: kexec@lists.infradead.org
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Dave Young <dyoung@redhat.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: Simon Horman <horms@verge.net.au>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1D0376B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 07:27:06 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so3551639wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 04:27:05 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id 9si32718192wjv.112.2015.09.01.04.27.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 04:27:04 -0700 (PDT)
Received: by wicmc4 with SMTP id mc4so29433125wic.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 04:27:04 -0700 (PDT)
Message-ID: <55E58B85.2010309@plexistor.com>
Date: Tue, 01 Sep 2015 14:27:01 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901100804.GA7045@node.dhcp.inet.fi>
In-Reply-To: <20150901100804.GA7045@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/01/2015 01:08 PM, Kirill A. Shutemov wrote:
<>
> 
> Is that because XFS doesn't provide vm_ops->pfn_mkwrite?
> 

Right that would explain it, because I sent that patch exactly to solve
this problem. I haven't looked at latest code for a while but I should
checkout the latest and make a patch for xfs if it is indeed missing.

Thanks
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

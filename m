Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 448E76B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 06:29:04 -0400 (EDT)
Received: by wiclp12 with SMTP id lp12so13916569wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 03:29:03 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id ff10si38990398wjc.32.2015.09.02.03.29.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 03:29:03 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so12553777wic.1
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 03:29:02 -0700 (PDT)
Message-ID: <55E6CF6B.7060005@plexistor.com>
Date: Wed, 02 Sep 2015 13:28:59 +0300
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [PATCH] dax, pmem: add support for msync
References: <1441047584-14664-1-git-send-email-ross.zwisler@linux.intel.com> <20150831233803.GO3902@dastard> <20150901100804.GA7045@node.dhcp.inet.fi> <20150901224922.GR3902@dastard> <20150902091321.GA2323@node.dhcp.inet.fi> <55E6C36C.3090402@plexistor.com> <55E6C458.3040901@plexistor.com> <20150902094739.GA2627@node.dhcp.inet.fi>
In-Reply-To: <20150902094739.GA2627@node.dhcp.inet.fi>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@osdl.org>, x86@kernel.org, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Christoph Hellwig <hch@lst.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 09/02/2015 12:47 PM, Kirill A. Shutemov wrote:
<>
> 
> I don't insist on applying the patch. And I worry about false-positives.
> 

Thanks, yes
Boaz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

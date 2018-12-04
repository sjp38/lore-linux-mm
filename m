Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EBBCD6B6F98
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 11:22:39 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c7so17060278qkg.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 08:22:39 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id e17si2463725qkj.109.2018.12.04.08.22.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 08:22:37 -0800 (PST)
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
 <20181113063601.GT21824@bombadil.infradead.org>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
Date: Tue, 4 Dec 2018 11:22:34 -0500
MIME-Version: 1.0
In-Reply-To: <20181113063601.GT21824@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm@kvack.org, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>

On 11/13/18 1:36 AM, Matthew Wilcox wrote:
> On Mon, Nov 12, 2018 at 10:46:35AM -0500, Tony Battersby wrote:
>> Prevent a possible endless loop with DMAPOOL_DEBUG enabled if a buggy
>> driver corrupts DMA pool memory.
>>
>> Signed-off-by: Tony Battersby <tonyb@cybernetics.com>
> I like it!  Also, here you're using blks_per_alloc in a way which isn't
> normally in the performance path, but might be with the right config
> options.  With that, I withdraw my objection to the previous patch and
>
> Acked-by: Matthew Wilcox <willy@infradead.org>
>
> Andrew, can you funnel these in through your tree?  If you'd rather not,
> I don't mind stuffing them into a git tree and asking Linus to pull
> for 4.21.
>
No reply for 3 weeks, so adding Andrew Morton to recipient list.

Andrew, I have 9 dmapool patches ready for merging in 4.21.  See Matthew
Wilcox's request above.

Tony Battersby

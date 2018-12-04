Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5323E6B70C6
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 16:26:55 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id 98so17825215qkp.22
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 13:26:55 -0800 (PST)
Received: from mail.cybernetics.com (mail.cybernetics.com. [173.71.130.66])
        by mx.google.com with ESMTPS id y188si399281qke.85.2018.12.04.13.26.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Dec 2018 13:26:54 -0800 (PST)
Subject: Re: [PATCH v4 9/9] dmapool: debug: prevent endless loop in case of
 corruption
References: <9e65ec2e-5e22-4f65-7b92-ca2af0c555f3@cybernetics.com>
 <20181113063601.GT21824@bombadil.infradead.org>
 <4dcb22b0-a348-841d-8175-e368f67f33c3@cybernetics.com>
 <20181204121443.1430883634a6ecf5f4a6a4a2@linux-foundation.org>
 <20181204201801.GS10377@bombadil.infradead.org>
 <CAHp75VeCHnUcE8mfUkx_uXz9_ZoA+hAvVtFiFP+nLj4rJevBdw@mail.gmail.com>
From: Tony Battersby <tonyb@cybernetics.com>
Message-ID: <495c7e22-9332-1654-9ee0-63c33fae980e@cybernetics.com>
Date: Tue, 4 Dec 2018 16:26:51 -0500
MIME-Version: 1.0
In-Reply-To: <CAHp75VeCHnUcE8mfUkx_uXz9_ZoA+hAvVtFiFP+nLj4rJevBdw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Shevchenko <andy.shevchenko@gmail.com>, Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, iommu@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, linux-scsi <linux-scsi@vger.kernel.org>

On 12/4/18 3:30 PM, Andy Shevchenko wrote:
> On Tue, Dec 4, 2018 at 10:18 PM Matthew Wilcox <willy@infradead.org> wrote:
>> On Tue, Dec 04, 2018 at 12:14:43PM -0800, Andrew Morton wrote:
>>> Also, Andy had issues with the v2 series so it would be good to hear an
>>> update from him?
>> Certainly.
> Hmm... I certainly forgot what was long time ago.
> If I _was_ in Cc list and didn't comment, I'm fine with it.
>
v4 of the patchset is the same as v3 but with the last patch dropped. 
Andy had only one minor comment on v3 about the use of division in patch
#8, to which I replied.  That was back on August 8.

Tony

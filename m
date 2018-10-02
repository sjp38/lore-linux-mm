Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D2DB16B0272
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:50:23 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d200-v6so1866673qkc.22
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:50:23 -0700 (PDT)
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id q36-v6si4603099qvh.74.2018.10.02.07.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 02 Oct 2018 07:50:23 -0700 (PDT)
Date: Tue, 2 Oct 2018 14:50:22 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [STABLE PATCH] slub: make ->cpu_partial unsigned int
In-Reply-To: <20180930132333.GA10872@bombadil.infradead.org>
Message-ID: <01000166354231f3-1e953571-f9ec-4a73-a228-ff3692825b41-000000@email.amazonses.com>
References: <1538303301-61784-1-git-send-email-zhongjiang@huawei.com> <20180930125038.GA2533@bombadil.infradead.org> <20180930131026.GA25677@kroah.com> <20180930132333.GA10872@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Greg KH <gregkh@linux-foundation.org>, zhong jiang <zhongjiang@huawei.com>, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, mgorman@suse.de, vbabka@suse.cz, andrea@kernel.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 30 Sep 2018, Matthew Wilcox wrote:

> > And the patch in mainline has Christoph's ack...
>
> I'm not saying there's a problem with the patch.  It's that the rationale
> for backporting doesn't make any damned sense.  There's something going
> on that nobody understands.  This patch is probably masking an underlying
> problem that will pop back up and bite us again someday.

Right. That is why I raised the issue. I do not see any harm in
backporting but I do not think it fixes the real issue which may be in
concurrent use of page struct fields that are overlapping.

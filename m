Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id C36FD900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 09:03:27 -0400 (EDT)
Received: by obcwp4 with SMTP id wp4so1316894obc.4
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 06:03:27 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s5si709437pdc.152.2015.03.10.06.03.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 06:03:26 -0700 (PDT)
Date: Tue, 10 Mar 2015 06:03:23 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] shmem: Add eventfd notification on utlilization level
Message-ID: <20150310130323.GA1515@infradead.org>
References: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
 <1423666208-10681-2-git-send-email-k.kozlowski@samsung.com>
 <CAH9JG2X5qO418qp3_ZAvwE7LPe6YC_FdKkOwHtpYxzqZkUvB_w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAH9JG2X5qO418qp3_ZAvwE7LPe6YC_FdKkOwHtpYxzqZkUvB_w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Jan Kara <jack@suse.cz>

On Tue, Mar 10, 2015 at 10:51:41AM +0900, Kyungmin Park wrote:
> Any updates?

Please just add disk quota support to tmpfs so thast the standard quota
netlink notifications can be used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

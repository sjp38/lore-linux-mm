Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3F235900020
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 10:22:45 -0400 (EDT)
Received: by wiwl15 with SMTP id l15so30605172wiw.4
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 07:22:44 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fj7si4497707wic.71.2015.03.10.07.22.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Mar 2015 07:22:43 -0700 (PDT)
Date: Tue, 10 Mar 2015 15:22:37 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] shmem: Add eventfd notification on utlilization level
Message-ID: <20150310142237.GA2095@quack.suse.cz>
References: <1423666208-10681-1-git-send-email-k.kozlowski@samsung.com>
 <1423666208-10681-2-git-send-email-k.kozlowski@samsung.com>
 <CAH9JG2X5qO418qp3_ZAvwE7LPe6YC_FdKkOwHtpYxzqZkUvB_w@mail.gmail.com>
 <20150310130323.GA1515@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150310130323.GA1515@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kyungmin Park <kmpark@infradead.org>, Krzysztof Kozlowski <k.kozlowski@samsung.com>, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Jan Kara <jack@suse.cz>

On Tue 10-03-15 06:03:23, Christoph Hellwig wrote:
> On Tue, Mar 10, 2015 at 10:51:41AM +0900, Kyungmin Park wrote:
> > Any updates?
> 
> Please just add disk quota support to tmpfs so thast the standard quota
> netlink notifications can be used.
  If I understand the problem at hand, they are really interested in
notification when running out of free space. Using quota for that doesn't
seem ideal since that tracks used space per user, not free space on fs as a
whole.

But if I remember right there were discussions about ENOSPC notification
from filesystem for thin provisioning usecases. It would be good to make
this consistent with those but I'm not sure if it went anywhere.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

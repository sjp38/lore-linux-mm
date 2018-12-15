Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] fix page_count in ->iomap_migrate_page()
Date: Sat, 15 Dec 2018 12:17:01 +0100
Message-ID: <140465544.WOeLnmPe7Q@blindfold>
In-Reply-To: <20181215105112.GC1575@lst.de>
References: <1544766961-3492-1-git-send-email-openzhangj@gmail.com> <1618433.IpySj692Hd@blindfold> <20181215105112.GC1575@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: linux-kernel-owner@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Cc: zhangjun <openzhangj@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, bfoster@redhat.com, Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, aarcange@redhat.com, willy@infradead.org, linux@dominikbrodowski.net, linux-mm@kvack.org, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-mm.kvack.org>

Am Samstag, 15. Dezember 2018, 11:51:12 CET schrieb Christoph Hellwig:
> FYI, for iomap we got a patch to just increment the page count when
> setting the private data, and it finally got merged into mainline after
> a while.
> 
> Not that it totally makes sense to me, but it is what it is.  It would
> just be nice if set_page_private took care of it and we had a
> clear_page_private to undo it, making the whole scheme at lot more
> obvious.

Yeah, UBIFS will go the same route. I have already a patch prepared
which increments the page count when UBIFS sets PG_private.

Thanks,
//richard

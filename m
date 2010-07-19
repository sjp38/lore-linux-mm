Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 209226007F7
	for <linux-mm@kvack.org>; Mon, 19 Jul 2010 14:45:09 -0400 (EDT)
From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [PATCH] fix return value for mb_cache_shrink_fn when nr_to_scan > 0
Date: Mon, 19 Jul 2010 20:40:08 +0200
References: <4C425273.5000702@gmail.com> <20100718060106.GA579@infradead.org> <4C42A10B.2080904@gmail.com>
In-Reply-To: <4C42A10B.2080904@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Message-Id: <201007192040.09062.agruen@suse.de>
Sender: owner-linux-mm@kvack.org
To: Wang Sheng-Hui <crosslonelyover@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Eric Sandeen <sandeen@redhat.com>, linux-fsdevel@vger.kernel.org, viro@zeniv.linux.org.uk, linux-mm@kvack.org, linux-ext4 <linux-ext4@vger.kernel.org>, kernel-janitors <kernel-janitors@vger.kernel.org>, a.gruenbacher@computer.org
List-ID: <linux-mm.kvack.org>

On Sunday 18 July 2010 08:36:59 Wang Sheng-Hui wrote:
> =E4=BA=8E 2010-7-18 14:01, Christoph Hellwig =E5=86=99=E9=81=93:
> > This should be using list_for_each_entry.

It would make sense to change this throughout the whole file.

Thanks,
Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

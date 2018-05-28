Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCCE76B0007
	for <linux-mm@kvack.org>; Mon, 28 May 2018 03:30:16 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id t1-v6so7554417oth.3
        for <linux-mm@kvack.org>; Mon, 28 May 2018 00:30:16 -0700 (PDT)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id g7-v6si507210oth.232.2018.05.28.00.30.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 May 2018 00:30:15 -0700 (PDT)
Subject: Re: [RESEND PATCH V5 24/33] f2fs: conver to bio_for_each_page_all2
References: <20180525034621.31147-1-ming.lei@redhat.com>
 <20180525034621.31147-25-ming.lei@redhat.com>
From: Chao Yu <yuchao0@huawei.com>
Message-ID: <5cb89f28-9f7d-7423-b0a0-2b217a406738@huawei.com>
Date: Mon, 28 May 2018 15:29:38 +0800
MIME-Version: 1.0
In-Reply-To: <20180525034621.31147-25-ming.lei@redhat.com>
Content-Type: text/plain; charset="windows-1252"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <ming.lei@redhat.com>, Jens Axboe <axboe@fb.com>, Christoph
 Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>

On 2018/5/25 11:46, Ming Lei wrote:
> bio_for_each_page_all() can't be used any more after multipage bvec is
> enabled, so we have to convert to bio_for_each_page_all2().
> 
> Signed-off-by: Ming Lei <ming.lei@redhat.com>

Acked-by: Chao Yu <yuchao0@huawei.com>

Thanks,

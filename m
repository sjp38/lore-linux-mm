Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D94A8C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:30:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BEC42184D
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:30:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Cwuh9Bn4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BEC42184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A9358E0003; Tue, 26 Feb 2019 10:30:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 259E08E0001; Tue, 26 Feb 2019 10:30:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 170178E0003; Tue, 26 Feb 2019 10:30:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DFD758E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:30:40 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k1so12619438qta.2
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:30:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=RXpuypGPaxLuzfXK4JIKNMVV6wX+/Dvo+AtpUQerBu8=;
        b=mpS33g9FDfRiIJM6nfpFpqdCufHhIto3JGYKx8G35sOJE7sKCdnCVJk0ecJ1fvlmVx
         S78calby7s5yH/Z4uDDXEZ0aZ3Tgm7Kpdm/E48qSnm5KKfXZEq7/Rvo3KUUIMyN9w8Jp
         hRTOb0WTD3n/q4ESAOBJ5z06gHBiIUwIL8soQVx+m0uC/uKJ7EiDtJ4pXzZ96x/hHYsY
         U9Jab3/f2rLlR65PNY47PiACAYcdFIaKgbsZKcuCtB6h/ERODj+0LGqKpdt9rvn8dv4p
         0k7w14lVBA6Wp/55gR0FhKWbxmMaDKvGQoUi0k2eXlJxbni3a4qi6UGJGtbXe7iiaXbh
         GuOg==
X-Gm-Message-State: AHQUAuZQogJyEZfEyKVtzukaPX/304pRaZwaaVuROP+h1TiaT4arlWoW
	xGrLas9EP2fNzCkjPnpZq5YQAHJ4H6Cn3Vhg4rQDCMp/+6HfCDFM8G8JOmq23zR7PGEMEnca7eD
	zatMgPwsvhk1z/x/27o6S367l0Nrtno2FkCRMS27ppVhMX5uKU022PT2m9MJ4edk=
X-Received: by 2002:ac8:38d5:: with SMTP id g21mr17870719qtc.237.1551195040557;
        Tue, 26 Feb 2019 07:30:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYyiyflKkdQTXTghHHgnSGRHYPehXm5KUzDk57vIEoUbmY2gwUrqmQOS11MaH19GIryLK4v
X-Received: by 2002:ac8:38d5:: with SMTP id g21mr17870675qtc.237.1551195039835;
        Tue, 26 Feb 2019 07:30:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551195039; cv=none;
        d=google.com; s=arc-20160816;
        b=M9rnbnw9+9iDmEi1VBd5A6lE4Ui6/78oWw3AsD5ES+mhBG1CfgSENt2LlRiIWHjzAD
         a+fjWbyZAC4R+hGyRfPdV278GpbFAO4LBDwheWaCmkUWMtfFihNBPPR4BSbivg27oxfA
         U/FlmKG5DDrudxebXeC8noe9B7psXGDyxofZk4gUsXlh4WWBi6zmGH8FeN08g3L6ihb/
         iK6JqjhCERtEBfreNBkp9TWAz58drgVeiFWOelJuyylq3JKT3NSBTFXNumCItj3H8B/Y
         1uy3ClenhqzBd7AyF3gKmUaQWSC9dbqWjR9TBGW0gUqCUzclpBCFAGmdNDHoZWFTeaDf
         BcwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=RXpuypGPaxLuzfXK4JIKNMVV6wX+/Dvo+AtpUQerBu8=;
        b=aJWTBXH97ibQ5kY0Fa8R6zMgExv6FinK2KQhKYdA12MFVKmemgkKG2yOwQH24Ta1tE
         Gd+Ur7tBpfAlmuKuKcvGSdUucAEafKf0iNZiVP7FdPHjKLgBrsE/uaKp+sJWJKemxqmO
         RzfQmwpK+qsvR7xWfzbhzHKjPc035cXYu2zlSC2b7xHOITLLvWWS+jQyGSqIz+Wmbmwk
         m/oQJbcXpRiVeJxjjwNpKyjyG3FQ25YUGklWkomml3TGUNEX3st5DA0jbRu/lv0KpeE/
         Xydtk6yLiTr36EaznIhwN79vm0d2hs/zV5LkiCNMYATk1w2E9LtbQaK3Pu+JL7tF8qHO
         KB4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Cwuh9Bn4;
       spf=pass (google.com: domain of 010001692a6de63c-e2304a50-263c-49c5-a9fd-675cfb7094f5-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=010001692a6de63c-e2304a50-263c-49c5-a9fd-675cfb7094f5-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id g11si749609qtc.86.2019.02.26.07.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 26 Feb 2019 07:30:39 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001692a6de63c-e2304a50-263c-49c5-a9fd-675cfb7094f5-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Cwuh9Bn4;
       spf=pass (google.com: domain of 010001692a6de63c-e2304a50-263c-49c5-a9fd-675cfb7094f5-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=010001692a6de63c-e2304a50-263c-49c5-a9fd-675cfb7094f5-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1551195039;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=77D7T9rT28LezgnI2F/Twf1vqeCxGWnkTDI0cd2LU9M=;
	b=Cwuh9Bn4YOPwc2G8avlvb5V/KpMzxNjiYRZ1hYABExxhazCjWYiVSX+UHzSMKyQ1
	t4e4Rr+n3WKwVxJi9PsH29vdbsKLRAUAnjunUVA1v1G7OIP8hdgR4+hy6PyNLlxPkg4
	oj7KrZdC1aWUP08xzNIwp4HY7tQ1ugjnmcis6dNI=
Date: Tue, 26 Feb 2019 15:30:39 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Ming Lei <ming.lei@redhat.com>
cc: Matthew Wilcox <willy@infradead.org>, Ming Lei <tom.leiming@gmail.com>, 
    Vlastimil Babka <vbabka@suse.cz>, Dave Chinner <david@fromorbit.com>, 
    "Darrick J . Wong" <darrick.wong@oracle.com>, 
    "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, 
    Jens Axboe <axboe@kernel.dk>, Vitaly Kuznetsov <vkuznets@redhat.com>, 
    Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>, 
    Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
    Aaron Lu <aaron.lu@intel.com>, 
    Linux FS Devel <linux-fsdevel@vger.kernel.org>, 
    linux-mm <linux-mm@kvack.org>, linux-block <linux-block@vger.kernel.org>, 
    Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via
 page_frag_alloc
In-Reply-To: <20190226134247.GA30942@ming.t460p>
Message-ID: <010001692a6de63c-e2304a50-263c-49c5-a9fd-675cfb7094f5-000000@email.amazonses.com>
References: <20190226022249.GA17747@ming.t460p> <20190226030214.GI23020@dastard> <20190226032737.GA11592@bombadil.infradead.org> <20190226045826.GJ23020@dastard> <20190226093302.GA24879@ming.t460p> <a641feb8-ceb2-2dac-27aa-7b1df10f5ae5@suse.cz>
 <CACVXFVMX=WpTRBbDTSibfXkTZxckk3ootetbE+rkJtHhsZkRAw@mail.gmail.com> <20190226121209.GC11592@bombadil.infradead.org> <20190226123545.GA6163@ming.t460p> <20190226130230.GD11592@bombadil.infradead.org> <20190226134247.GA30942@ming.t460p>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.26-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2019, Ming Lei wrote:

> Then something like the following patch should work for all fs, could
> anyone comment on this approach?

Note that various subsystems have similar implementations. Have a look at

drivers/dma/dmaengine.c

struct dmaengine_unmap_pool {
        struct kmem_cache *cache;
        const char *name;
        mempool_t *pool;
        size_t size;
};

#define __UNMAP_POOL(x) { .size = x, .name = "dmaengine-unmap-"
__stringify(x) }
static struct dmaengine_unmap_pool unmap_pool[] = {
        __UNMAP_POOL(2),
        #if IS_ENABLED(CONFIG_DMA_ENGINE_RAID)
        __UNMAP_POOL(16),
        __UNMAP_POOL(128),
        __UNMAP_POOL(256),
        #endif
};

Or drivers/md/dm-bufio.c:

struct dm_bufio_client {
        struct mutex lock;

        struct list_head lru[LIST_SIZE];
        unsigned long n_buffers[LIST_SIZE];

        struct block_device *bdev;
        unsigned block_size;
        s8 sectors_per_block_bits;
        void (*alloc_callback)(struct dm_buffer *);
        void (*write_callback)(struct dm_buffer *);

        struct kmem_cache *slab_buffer;
        struct kmem_cache *slab_cache;
        struct dm_io_client *dm_io;

        struct list_head reserved_buffers;
        unsigned need_reserved_buffers;

        unsigned minimum_buffers;

        struct rb_root buffer_tree;
        wait_queue_head_t free_buffer_wait;

        sector_t start;

        int async_write_error;

        struct list_head client_list;
        struct shrinker shrinker;
};


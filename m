Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 653946B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 02:21:02 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id fq2so14887363obb.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 23:21:02 -0700 (PDT)
Received: from mail-it0-x235.google.com (mail-it0-x235.google.com. [2607:f8b0:4001:c0b::235])
        by mx.google.com with ESMTPS id l76si12457182itb.7.2016.06.27.23.21.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 23:21:01 -0700 (PDT)
Received: by mail-it0-x235.google.com with SMTP id a5so84022174ita.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 23:21:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160627083924.GA31803@dhcp22.suse.cz>
References: <CADUS3omw4c3Q8W76RK254Kd=yqokBCPysJ0Y7rRJGpRj4zEv4A@mail.gmail.com>
 <20160627083924.GA31803@dhcp22.suse.cz>
From: yoma sophian <sophian.yoma@gmail.com>
Date: Tue, 28 Jun 2016 14:21:00 +0800
Message-ID: <CADUS3o=16nLHg4dNG6FiZJ59LFst-fDROJ-vmC8q6BT249RtCA@mail.gmail.com>
Subject: Re: some question about vma_interval_tree_insert
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org

hi Michael:
> See
> INTERVAL_TREE_DEFINE(struct vm_area_struct, shared.rb,
>                      unsigned long, shared.rb_subtree_last,
>                      vma_start_pgoff, vma_last_pgoff,, vma_interval_tree)
appreciate your kind help ^^

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

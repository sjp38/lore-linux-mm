Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6E36B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 04:39:28 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a4so114973563lfa.1
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:39:27 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id r2si24924152wjd.215.2016.06.27.01.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 01:39:26 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id a66so104134130wme.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 01:39:26 -0700 (PDT)
Date: Mon, 27 Jun 2016 10:39:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: some question about vma_interval_tree_insert
Message-ID: <20160627083924.GA31803@dhcp22.suse.cz>
References: <CADUS3omw4c3Q8W76RK254Kd=yqokBCPysJ0Y7rRJGpRj4zEv4A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3omw4c3Q8W76RK254Kd=yqokBCPysJ0Y7rRJGpRj4zEv4A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

On Mon 27-06-16 16:28:03, yoma sophian wrote:
> hi all:
> I try to find out where the function, vma_interval_tree_insert,
> implemented but in vain.

See
INTERVAL_TREE_DEFINE(struct vm_area_struct, shared.rb,
		     unsigned long, shared.rb_subtree_last,
		     vma_start_pgoff, vma_last_pgoff,, vma_interval_tree)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

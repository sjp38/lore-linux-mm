Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 82AA76B031C
	for <linux-mm@kvack.org>; Wed, 16 May 2018 07:16:13 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e18-v6so179086pgt.3
        for <linux-mm@kvack.org>; Wed, 16 May 2018 04:16:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u7-v6si2435737plq.160.2018.05.16.04.16.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 16 May 2018 04:16:12 -0700 (PDT)
Date: Wed, 16 May 2018 13:13:29 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 06/14] btrfs: separate errno from VM_FAULT_* values
Message-ID: <20180516111329.GZ6649@twin.jikos.cz>
Reply-To: dsterba@suse.cz
References: <20180516054348.15950-1-hch@lst.de>
 <20180516054348.15950-7-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180516054348.15950-7-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, Matthew Wilcox <willy@infradead.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@lists.orangefs.org, ceph-devel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mtd@lists.infradead.org, dri-devel@lists.freedesktop.org, lustre-devel@lists.lustre.org, linux-arm-kernel@lists.infradead.org, linux-s390@vger.kernel.org

On Wed, May 16, 2018 at 07:43:40AM +0200, Christoph Hellwig wrote:
> Signed-off-by: Christoph Hellwig <hch@lst.de>

Reviewed-by: David Sterba <dsterba@suse.com>

I can add it to the btrfs queue now, unless you need the patch for the
rest of the series.

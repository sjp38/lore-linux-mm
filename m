Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 769306B0007
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 14:29:02 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j9-v6so12492023plt.3
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:29:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b13-v6si12575586plm.275.2018.10.15.11.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 15 Oct 2018 11:29:01 -0700 (PDT)
Date: Mon, 15 Oct 2018 11:28:58 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 16/25] vfs: make remapping to source file eof more
 explicit
Message-ID: <20181015182855.GA20655@infradead.org>
References: <153938912912.8361.13446310416406388958.stgit@magnolia>
 <153938925737.8361.3995899966552253527.stgit@magnolia>
 <20181014172433.GG30673@infradead.org>
 <20181015153219.GG28243@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181015153219.GG28243@magnolia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, david@fromorbit.com, sandeen@redhat.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>, linux-unionfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-mm@kvack.org, linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, ocfs2-devel@oss.oracle.com

On Mon, Oct 15, 2018 at 08:32:19AM -0700, Darrick J. Wong wrote:
> > Why not put that in the name to make it more descriptive?
> 
> I'm all ears for better suggestions. :)

I think the best idea is no flag - just carry through the special
zero..

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C6496B000A
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 10:37:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id d40-v6so2831981pla.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 07:37:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y2-v6si16291993pli.330.2018.10.02.07.37.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 Oct 2018 07:37:18 -0700 (PDT)
Date: Tue, 2 Oct 2018 07:37:13 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002143713.GA19845@infradead.org>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002142959.GD9127@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Johannes Thumshirn <jthumshirn@suse.de>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

On Tue, Oct 02, 2018 at 04:29:59PM +0200, Jan Kara wrote:
> > OK naive question from me, how do we want an application to be able to
> > check if it is running on a DAX mapping?
> 
> The question from me is: Should application really care?

No, it should not.  DAX is an implementation detail thay may change
or go away at any time.

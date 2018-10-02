Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D39456B027E
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 11:07:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id 31-v6so68191edr.19
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 08:07:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u21si4552347edy.88.2018.10.02.08.07.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 08:07:09 -0700 (PDT)
Date: Tue, 2 Oct 2018 17:07:08 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Problems with VM_MIXEDMAP removal from /proc/<pid>/smaps
Message-ID: <20181002150708.GF9127@quack2.suse.cz>
References: <20181002100531.GC4135@quack2.suse.cz>
 <20181002121039.GA3274@linux-x5ow.site>
 <20181002142959.GD9127@quack2.suse.cz>
 <20181002143713.GA19845@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181002143713.GA19845@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jan Kara <jack@suse.cz>, Johannes Thumshirn <jthumshirn@suse.de>, Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org

On Tue 02-10-18 07:37:13, Christoph Hellwig wrote:
> On Tue, Oct 02, 2018 at 04:29:59PM +0200, Jan Kara wrote:
> > > OK naive question from me, how do we want an application to be able to
> > > check if it is running on a DAX mapping?
> > 
> > The question from me is: Should application really care?
> 
> No, it should not.  DAX is an implementation detail thay may change
> or go away at any time.

I agree that whether / how pagecache is used for filesystem access is an
implementation detail of the kernel.  OTOH for some workloads it is about
whether kernel needs gigabytes of RAM to cache files or not, which is not a
detail anymore if you want to fully utilize the machine. So people will be
asking for this and will be finding odd ways to determine whether DAX is
used or not (such as poking in smaps). And once there is some widely enough
used application doing this, it is not "stupid application" problem anymore
but the kernel's problem of not maintaining backward compatibility.

So I think we would be better off providing *some* API which applications
can use to determine whether pagecache is used or not and make sure this
API will convey the right information even if we change DAX
implementation or remove it altogether.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1578E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 17:16:14 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s70so26972qks.4
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 14:16:14 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p11si21452qtn.50.2018.12.12.14.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 14:16:13 -0800 (PST)
Date: Wed, 12 Dec 2018 17:16:07 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181212221607.GJ5037@redhat.com>
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212221157.GL6830@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181212221157.GL6830@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 02:11:57PM -0800, Matthew Wilcox wrote:
> On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
> > The mmu notifier i put forward is the emergency revoke ie last
> > resort after driver have done everything it could to inform user-
> > space and release the pages. So doing thing brutaly in it like
> > reprogramming driver page table (which AFAIK is something you
> > can do on any hardware wether the hardware will like it or not
> > is a different question).
> 
> You can't do it to an NVMe device.  You submit the DMA addresses in
> the command, and the device reads the command at submission time.
> There's no way to change the DMA addresses for an in-flight command.

But like for GPU you can wait for in flight commands right ? ie
you can wait for the queue to be done. This is how GPU do GUP ie
GUP submit commands to queue and wait in mmu notifier for queue
to be done.

CHeers,
J�r�me

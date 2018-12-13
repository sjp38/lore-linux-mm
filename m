Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E4E7C8E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 22:26:40 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id a19so306589otq.1
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 19:26:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k29sor326648otf.116.2018.12.12.19.26.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 19:26:39 -0800 (PST)
Date: Wed, 12 Dec 2018 20:26:37 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213032637.GB3204@ziepe.ca>
References: <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com>
 <20181212233703.GB2947@ziepe.ca>
 <20181213000109.GK5037@redhat.com>
 <CAPcyv4ii6hyrNj=fijoZ1no8w6N1Kk2jGZyWCn7hFKNKaNsyXQ@mail.gmail.com>
 <20181213004437.GL5037@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213004437.GL5037@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On Wed, Dec 12, 2018 at 07:44:37PM -0500, Jerome Glisse wrote:

> On many GPUs you can do that, it is hardware dependant and you have
> steps to take but it is something you can do (and GPU can do
> continuous DMA traffic have they have threads running that can
> do continuous memory access). So i assume that other hardware
> can do it too.

RDMA has no generic way to modify a MR and then guarntee the HW sees
the modifications. Some HW can do this (ie the same HW that can do
ODP, because ODP needs this capability), other HW is an unknown as
this has never been asked for as a driver API.

Jason

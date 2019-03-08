Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E49E4C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:58:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C8E520675
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 02:58:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="LUhUl4n6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C8E520675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1526F8E0004; Thu,  7 Mar 2019 21:58:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 129718E0002; Thu,  7 Mar 2019 21:58:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0189D8E0004; Thu,  7 Mar 2019 21:58:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id CDE7D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 21:58:49 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b11so15014568qka.3
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 18:58:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=sonndpxj6vuFpIuGlZRJ1d8q8dyAzBnQv9cXzFfpozk=;
        b=kpLCOmiQRkqYwZ5IM4Q9vRrdftQQB+F0lbl7PdMVvtoYYO113RKoMTOnDZsc/wJSVU
         tLfK/1RDQI3IJQ+O75WuIQ+H9TkNUQ/uJKkLJj6+Elp3H6xz4aJdjIHxZiZPH6iG/I/v
         gKhqh9li+e5tFdAzRvj/CvKbIb03/rXrymh+U+Ak27/lhNhyzr6GwkOqUYOb/W9o2+7y
         3dvGqBS92VNba2xq2NZAxummaIwT/ghlLofT/Bw2UnY/Df+cp/p2yuVq2R3sKBuYnj1k
         Q9sGSyBekpQVJBAIAt7boUetsxBZY9Rvmct9SpB06N7QyNnTbvK7oG+FQlEEA5aCtXzn
         u2qg==
X-Gm-Message-State: APjAAAXnhOF80ppZ2Rjl1l2NlUelleList8z8wJbJc1KY6sQCYtesfs6
	ifOkmVc6rnyr9s9ORjedC26uPdzbgAExZz/6sVY1tPy3J8H2hgYL3c2hQU+zM7rmzWmQJOan/Br
	Pkdt1zxhJCLNoBTox6Yur635o+9kG3ZJ8Z1e1Pcv+a2HbumQNKVPRAgyUaNXNN9E=
X-Received: by 2002:a0c:8698:: with SMTP id 24mr13499711qvf.188.1552013929573;
        Thu, 07 Mar 2019 18:58:49 -0800 (PST)
X-Google-Smtp-Source: APXvYqznJi3xcFQrJmb8PsbpMVt8L+xyq0vtz942HEwbtj6FFvVW+byal34gCBzGUmoqSZeh1hfX
X-Received: by 2002:a0c:8698:: with SMTP id 24mr13499683qvf.188.1552013928769;
        Thu, 07 Mar 2019 18:58:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552013928; cv=none;
        d=google.com; s=arc-20160816;
        b=QSksCDS+qw82XlG/apvHxT6558kaQC3nNBWrBHinQPdPX3Ryva4QlYfRtqaomttjqL
         qLWwPIxSZ7/mICOtWBcAOVjtLLw5IiH9fMlANquXWDajWR84bP4BD7hlEYTDuunElhtO
         gWyYRLBGpTQ5Ia3Lr9H4DZjeo12GMVW26ZMkeiMz9wz+TwTNzIz2iIQICcoGwCC6gUXy
         PXKBsuXTJDKxKDGYKv/OzoNm/tRU4sqZB5uCP0SBHf1i0Vi5G4K0PRH0U06SCCEyb1xB
         DVXWdExYXIL6gnkoF1RgheuvF26A3/2Kb66XkLIfi/rF4nY6cljJ4t2GSJxsb5rmN/Jc
         ABmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=sonndpxj6vuFpIuGlZRJ1d8q8dyAzBnQv9cXzFfpozk=;
        b=DiBH9brE/uwWiP9L/rKR6SJjWyUru0davzLuFM8s+d5/ls+zUhCo8b7GEfDQaCr7LV
         cTZcrrNlhlnTQxSOKU0Q8MOenQkiEPVt85Cd6aAiu8pQbLpbBCyWDARqXHBgartJ4rz/
         ukh6sdEPV4g/S2t/LGCBGejuKAVXJEQyG13pgTvVM1NEe2E7vVYpAAi4pNYLsBiegi7e
         oWnTd6Ur7EwpcMy7SW4smNDg/7nA7AsDLLbTNJSvdR1bc+BIftQDPsa1zeN2ESpi2V7l
         im//EgUsAaR1pwxOAg1ulJJb9DOlz6ZyZdNIsiCc0RQAfEorQ4bv0mMunGzra2+swRX5
         Bljg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=LUhUl4n6;
       spf=pass (google.com: domain of 010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@amazonses.com
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id o2si2764969qto.136.2019.03.07.18.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 18:58:48 -0800 (PST)
Received-SPF: pass (google.com: domain of 010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@amazonses.com designates 54.240.9.114 as permitted sender) client-ip=54.240.9.114;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=LUhUl4n6;
       spf=pass (google.com: domain of 010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@amazonses.com designates 54.240.9.114 as permitted sender) smtp.mailfrom=010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1552013928;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=itWZ1WtMJIGZ6hsAuOQydOeKK/mKEWYE0qj8U0Zh5dg=;
	b=LUhUl4n63lCPYiPmr2W/EC4A3CQqJvXLES+K1ez+E8EDvU0LfIcTIREwaehkqeC+
	Mpn7H4vdvNH0SkPUcyo2LXbZHPlZ/GZTsP0lkW/qQz5+HvI6uqWiZmUQVUdbt1L9iqT
	TMQi73k6EBDE7eSRQcr3OpbFo5DWBoWYCycMt2Mo=
Date: Fri, 8 Mar 2019 02:58:48 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: john.hubbard@gmail.com
cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
    Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, 
    Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
In-Reply-To: <20190306235455.26348-2-jhubbard@nvidia.com>
Message-ID: <010001695b3d2701-3215b423-7367-44d6-98bc-64fc2f84264a-000000@email.amazonses.com>
References: <20190306235455.26348-1-jhubbard@nvidia.com> <20190306235455.26348-2-jhubbard@nvidia.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.03.08-54.240.9.114
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 6 Mar 2019, john.hubbard@gmail.com wrote:

> Dave Chinner's description of this is very clear:
>
>     "The fundamental issue is that ->page_mkwrite must be called on every
>     write access to a clean file backed page, not just the first one.
>     How long the GUP reference lasts is irrelevant, if the page is clean
>     and you need to dirty it, you must call ->page_mkwrite before it is
>     marked writeable and dirtied. Every. Time."
>
> This is just one symptom of the larger design problem: filesystems do not
> actually support get_user_pages() being called on their pages, and letting
> hardware write directly to those pages--even though that patter has been
> going on since about 2005 or so.

Can we distinguish between real filesystems that actually write to a
backing device and the special filesystems (like hugetlbfs, shm and
friends) that are like anonymous memory and do not require
->page_mkwrite() in the same way as regular filesystems?

The use that I have seen in my section of the world has been restricted to
RDMA and get_user_pages being limited to anonymous memory and those
special filesystems. And if the RDMA memory is of such type then the use
in the past and present is safe.

So a logical other approach would be to simply not allow the use of
long term get_user_page() on real filesystem pages. I hope this patch
supports that?

It is customary after all that a file read or write operation involve one
single file(!) and that what is written either comes from or goes to
memory (anonymous or special memory filesystem).

If you have an mmapped memory segment with a regular device backed file
then you already have one file associated with a memory segment and a
filesystem that does take care of synchronizing the contents of the memory
segment to a backing device.

If you now perform RDMA or device I/O on such a memory segment then you
will have *two* different devices interacting with that memory segment. I
think that ought not to happen and not be supported out of the box. It
will be difficult to handle and the semantics will be hard for users to
understand.

What could happen is that the filesystem could agree on request to allow
third party I/O to go to such a memory segment. But that needs to be well
defined and clearly and explicitly handled by some mechanism in user space
that has well defined semantics for data integrity for the filesystem as
well as the RDMA or device I/O.




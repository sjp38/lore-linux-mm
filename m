Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BED7C282CC
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:21:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 156CE20821
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:21:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="eqqPaLK7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 156CE20821
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4AF8E0055; Mon,  4 Feb 2019 13:21:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A54B48E001C; Mon,  4 Feb 2019 13:21:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9439E8E0055; Mon,  4 Feb 2019 13:21:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 649E18E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:21:40 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so877048qtl.2
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:21:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=nirpWIDcnC5D/gqeHhqZEfTAwTpOapalA6vQSFEJlrg=;
        b=YRONbwbH1eeEt4bVmU0sEYZvSnHWiHdpDBJI1KEX9TuZyyRvZLEcPOgkxQM4f/Qdlx
         boI3FSnZK/siEUpo4+FMsxKhCY2uSEjHlgWUiBSvdpDN7OHkJbOy1wiSXfwMhbzo7vko
         FDwjz+ta1HVr4MepEQ5OcnlJFmRDVVLLRF3ecoe5mNHmw5r834J9UkZWPdaFagsVNWpB
         GA9plShk+xfJvdsw90faXYV3X6/Bxl+imQHTIpqIjJ8TG152U2OqDGCyi19E42CW69Hc
         Irimyg0pXdmwCwLzVX0Io2ppVbMoqRKj6IBd9owADbCmAd4lWC/t8lLz/P3BvL7MXEqD
         q/3g==
X-Gm-Message-State: AHQUAuaGDnUEgSU0a++jafWkti2G3uX60orign1MGltxbz2IFY5AgZSS
	1qLlcl6yVQIuoA2i1zxkKKLnYk5E1dfSn5NGc2IhgM4u+z/5Ubyg7uRETsRL0vTVMgBsSQsPwbs
	TABDscR/ZGuE1mrf2mbH2++AFJqPl3lebk87K5jgRDmS+rwrfh76YK0k3uOFFvdk=
X-Received: by 2002:ad4:5004:: with SMTP id s4mr560974qvo.109.1549304500163;
        Mon, 04 Feb 2019 10:21:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbLbxjo1puiF3o63bh6QkZA+4Fl1LimL0QKsIFqLxgLonxkalRvwS4V/BUMLuRJi5cAaw93
X-Received: by 2002:ad4:5004:: with SMTP id s4mr560945qvo.109.1549304499610;
        Mon, 04 Feb 2019 10:21:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304499; cv=none;
        d=google.com; s=arc-20160816;
        b=NznFPRyXtd1HH7R7TwJq3cDCKOtO5femsc65CXYPpZbzXyBgQ4FUSAzKGa1r1aLmAv
         XPlK4KaN24icuBzsLFHxoAeVPYRQjCQ7TRwuDJAtfb1Mmj1ATxy+sWHgYDzoi1qE5i1R
         +lGQSHju+a9ONiXYEYRanqd+i0rUQMpN+qo0veGSa2uw41efuchZmrZdg5sWbF0AuVQ6
         3mj0PvuJLhK/+cGsQNgUfXSaqR2vb/tBJBYNBeCXmJ+DUkRhPpiGuyOPPtVtrPPkTSrK
         mJ1eTdIc8MMZe57GjpGez3S78wJGS5Nd0qM7UVUbv9oRdlri15CIsUEU1yTkaohXbwFi
         1zjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=nirpWIDcnC5D/gqeHhqZEfTAwTpOapalA6vQSFEJlrg=;
        b=PTSvda5BtYmhWXlTsEhxczAGKsfbAQbTtyixwyjDomEADycpst2GuiTOksUZmtBzg+
         0ijFSZ6nBI4J0ZDjC4280218994XEo6VMUkAFod0VFhPpI6/W9fCI7a1nri5W76694M0
         Ux8nMO4NTDKMjQmPm/r4vV9fI3zVgGLfmgAYh4v55/1GZPldGqS817AOCCJB+y7gCkQ+
         t6wixg638Mg8lcZAkda1lYUATyU9glZhW+9VwmAH7+rj0ZOWxYydjk+SjJpjnMSkYpVc
         +Rdscf49HCQ63Wz0/t9wtFQjorXSIuVn4umJf1YHz4mMuS8KYC4+MWB3S4VMdlrLgpmn
         4oqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=eqqPaLK7;
       spf=pass (google.com: domain of 01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id z65si1652677qtc.247.2019.02.04.10.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Feb 2019 10:21:39 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=eqqPaLK7;
       spf=pass (google.com: domain of 01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1549304499;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=nirpWIDcnC5D/gqeHhqZEfTAwTpOapalA6vQSFEJlrg=;
	b=eqqPaLK753ERyVHOui9AhXNyEHkliLZNsy0bLhnJAXqdnvCX6SuwvNdVR6Ayg24Q
	BMtaV4Me15la7/pns5BOfhHu4OT8QcohddOIF2e3YaiR8izR0bS9HIiZjS5MZ13ecWq
	lMZeDm9mAAnkNvmVPhAU+QYsBOA41g0I/8sjbvd8=
Date: Mon, 4 Feb 2019 18:21:39 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Jason Gunthorpe <jgg@ziepe.ca>
cc: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>, 
    linux-mm@kvack.org, Al Viro <viro@zeniv.linux.org.uk>, 
    Christian Benvenuti <benve@cisco.com>, 
    Christoph Hellwig <hch@infradead.org>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Dave Chinner <david@fromorbit.com>, 
    Dennis Dalessandro <dennis.dalessandro@intel.com>, 
    Doug Ledford <dledford@redhat.com>, Jan Kara <jack@suse.cz>, 
    Jerome Glisse <jglisse@redhat.com>, Matthew Wilcox <willy@infradead.org>, 
    Michal Hocko <mhocko@kernel.org>, Mike Rapoport <rppt@linux.ibm.com>, 
    Mike Marciniszyn <mike.marciniszyn@intel.com>, 
    Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, 
    LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, 
    John Hubbard <jhubbard@nvidia.com>
Subject: Re: [PATCH 0/6] RFC v2: mm: gup/dma tracking
In-Reply-To: <20190204175110.GA10237@ziepe.ca>
Message-ID: <01000168b9be8b5a-3b4f8036-50c8-4180-b39f-9ef28cb60cce-000000@email.amazonses.com>
References: <20190204052135.25784-1-jhubbard@nvidia.com> <01000168b980e880-a7d8e0db-84fb-4398-8269-149c66b701b4-000000@email.amazonses.com> <20190204175110.GA10237@ziepe.ca>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.04-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 4 Feb 2019, Jason Gunthorpe wrote:

> On Mon, Feb 04, 2019 at 05:14:19PM +0000, Christopher Lameter wrote:
> > Frankly I still think this does not solve anything.
> >
> > Concurrent write access from two sources to a single page is simply wrong.
> > You cannot make this right by allowing long term RDMA pins in a filesystem
> > and thus the filesystem can never update part of its files on disk.
>
> Fundamentally this patch series is fixing O_DIRECT to not crash the
> kernel in extreme cases.. RDMA has the same problem, but it is much
> easier to hit.

O_DIRECT is the same issue. O_DIRECT addresses always have been in
anonymous memory or special file systems.


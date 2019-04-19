Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E591BC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:54:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 963C1217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 07:54:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 963C1217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 32C346B0007; Fri, 19 Apr 2019 03:54:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B2DC6B0008; Fri, 19 Apr 2019 03:54:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17AA06B000A; Fri, 19 Apr 2019 03:54:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E67AC6B0007
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 03:54:09 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id t22so4232727qtc.13
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 00:54:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=24BXTuW/EhPnKZ8NnL+p/VOsTv6JGW4q4dXtEym+ecs=;
        b=Bag+/QOEXXidhLCmOtWrWzUtMQQrX3MDT5yuJyha2p7EdO6ocAMI2J9wkqk91afd8J
         IgH4DlVy0uelWL0DSS83kxro52eoSKU8i5vSERYWptgCQdkBUg+w9LjWINs0TbuihaVP
         en4LTHb4FEoK+MQofwXYoA9j9h6MnmC8DlTgmDgi/tKmYN5IiN7TxQzDuyghD9jhm8Ll
         UJASr5U1u1iIEmYqz6yw2C3TiQSgr9FNsHgTR4aWGNgiqQZEp1u2FsqIgAPloTkJKiNn
         QpHzuYDsLZF9CZGqtPL+/mqY0qOsd29ag2j5yMLx568S3Hmj5HTtHivo5V5r0468KnZD
         KtOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBDlsvbpcWeVI6ILzn0zeXAmaD8wjQjFzE3NcEkDq60gTxZF11
	506kwBzZ8W4VIsKNxPXNf4WP553G35mYF4In29sVy5o9MVoHHp4k8ftI+SVy7sxe2hOpnkvjIsT
	iSlL6xt5hA300vh4EVweE+Wi9kHnC9QXfuTje8F6SrW8IOMLEW6zmqXAdyBri+bIDhA==
X-Received: by 2002:a37:784:: with SMTP id 126mr2057223qkh.10.1555660449724;
        Fri, 19 Apr 2019 00:54:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXjRH/Bw/3WlgurzY33FOgpkQqj8EtrY4C0o0M6v2f5Tk40YD+utkcDLBA0wt5Yjp6fSv/
X-Received: by 2002:a37:784:: with SMTP id 126mr2057201qkh.10.1555660449234;
        Fri, 19 Apr 2019 00:54:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555660449; cv=none;
        d=google.com; s=arc-20160816;
        b=YL6Cf+WXq5bHP5S3HJcugJS+i8LG9HvaWYLopJ15wqQWiNRdwEadT5fuqqgH9EeHAX
         ae/7pORnOwjSPFOsu1qHbbQ9JxpIfmJXHTXOztq1KzwfCCgY5RWoUrKxdtabAim6sH7D
         NRLFZw3g5omYxsvapJj6t+u25BwjLLo1lvC/Pl7lyYDF5R8M2M/QgmryWLv7ElVEQRxX
         hKqgVm9BNTI1iZKw0raDeklQfAlKH6ciSfUlxYu2KzYmmf5aWMSDbxGijt8hMujvt5KD
         gQpg2hM4Vg2jZO8TBKhjSUgcvDWnN+Pe0w5xFftNTzRmn8LCYyVbawbkD8VhG4WkzKHV
         +AIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=24BXTuW/EhPnKZ8NnL+p/VOsTv6JGW4q4dXtEym+ecs=;
        b=HFnGxowaakYoPs7zIEOMsGf60LYxk0t8e/hH0l+Nvn+0ZTDpEI0lVokNpio1K27hhe
         eyEy/p1FgAVDC5/VMmdgplL2Mg2cQwTZY2xFF/bq43GJwtAktNDuI/vwWAJp50aVgs/t
         srATt/ZNx8zMg6Ek4rbMUSPO+MUuULsWe+UUg0BOtO8H9j7LwQd/Cmcwkkl9dZI8DNjm
         k9RA+L6Lyb9i+LH/q/hFKXlrPNduD1T6EfDvlR64tRiVO9O95DOGAwB/R/yU1PLApGiv
         CUm/L+dciAxglCkzxGbyfv4eklSAZLyByw5YkXIYz2NLCKdz4YDDY7aUts693rA60+cL
         WoYA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d43si3522635qvd.59.2019.04.19.00.54.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 00:54:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 15149C067C0A;
	Fri, 19 Apr 2019 07:54:08 +0000 (UTC)
Received: from xz-x1 (ovpn-12-224.pek2.redhat.com [10.72.12.224])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id BB1185D9C5;
	Fri, 19 Apr 2019 07:53:57 +0000 (UTC)
Date: Fri, 19 Apr 2019 15:53:50 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 00/28] userfaultfd: write protection support
Message-ID: <20190419075350.GH13323@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190409060839.GE3389@xz-x1>
 <20190418210702.GN3288@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190418210702.GN3288@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 19 Apr 2019 07:54:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 05:07:02PM -0400, Jerome Glisse wrote:
> On Tue, Apr 09, 2019 at 02:08:39PM +0800, Peter Xu wrote:
> > On Wed, Mar 20, 2019 at 10:06:14AM +0800, Peter Xu wrote:
> > > This series implements initial write protection support for
> > > userfaultfd.  Currently both shmem and hugetlbfs are not supported
> > > yet, but only anonymous memory.  This is the 3nd version of it.
> > > 
> > > The latest code can also be found at:
> > > 
> > >   https://github.com/xzpeter/linux/tree/uffd-wp-merged
> > > 
> > > Note again that the first 5 patches in the series can be seen as
> > > isolated work on page fault mechanism.  I would hope that they can be
> > > considered to be reviewed/picked even earlier than the rest of the
> > > series since it's even useful for existing userfaultfd MISSING case
> > > [8].
> > 
> > Ping - any further comments for v3?  Is there any chance to have this
> > series (or the first 5 patches) for 5.2?
> 
> Few issues left, sorry for taking so long to get to review, sometimes
> it goes to the bottom of my stack.
> 
> I am guessing this should be merge through Andrew ? Unless Andrea have
> a tree for userfaultfd (i am not following all that closely).
> 
> From my point of view it almost all look good. I sent review before
> this email. Maybe we need some review from x86 folks on the x86 arch
> changes for the feature ?

Thank you for your time on reviewing the series (my thanks to Mike
too!).  I have no idea on anyone else I should ask for help for
further review comments, but anyway I'd be more than glad to discuss
with any further concerns or do anything to move this series forward.
Because AFAIK mutliple userspace projects are waiting for this series
to settle.

Thanks,

-- 
Peter Xu


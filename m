Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E094EC10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:07:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A88BA217D7
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 21:07:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A88BA217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7807A6B0005; Thu, 18 Apr 2019 17:07:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 708366B0006; Thu, 18 Apr 2019 17:07:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F7996B0007; Thu, 18 Apr 2019 17:07:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2AB6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 17:07:14 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id c28so3183832qtd.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 14:07:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=KP43xD+XX6SI0WFbf9e1APdiupecxwiSqel5wwcHzyM=;
        b=BIG+0HzT0zOYz15rbQqQq4gZrQlC20GSrN5BilOLvP0j3Y6mpdklt0J+K7GTs4l1tF
         jaUcjv1zhQxPYtnT0lpvZhEpj5tbL8kHRfrWjYgyLt6l8zNEwT/nZrjQwG0fpJIKLx2z
         PYpoy664cMgd3BJsAd0+5M25tCvTcTMyZMBTeojz34iTsQfK5E5j59LpAiQFKJqDhUH4
         Ya4rSk5yzNsARnwyzB7iIcAkd6bxVdTSWfjbS8foSMbvWMpnfqXzAZ/qeIMTo2F906ze
         zs9BYTMJJYQcM8V2DwxwoxhE1qfdtg1YFLyhxig/JKbQ77jxoFubBBH/2KUxBXAWBFIB
         ywUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVSlE6ttugTZ7DDipiu8W4EJvW8aM0lbaWU1QSkWavwk+z0IeM+
	HpoGKhguw+oXJCRYDA1t6IjJ1EbwSl99N8d47ZVkPXAdYzeEysePAY8NgKQX8pg2DWOTVxAm82d
	2Vme4tglhRLhPcBZnqJMBorZ5vcSLFNtGjzBBb+KFypusCREon+VoHxkWILZL/HjPrw==
X-Received: by 2002:a37:a543:: with SMTP id o64mr123246qke.235.1555621634012;
        Thu, 18 Apr 2019 14:07:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztZH2AI8uRU6rEiunpbx+RT7SupzKduCZ9+u5K9voEqMmkrtT8HGpuAmtCXc8nPWCY43F1
X-Received: by 2002:a37:a543:: with SMTP id o64mr123201qke.235.1555621633461;
        Thu, 18 Apr 2019 14:07:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555621633; cv=none;
        d=google.com; s=arc-20160816;
        b=xwuFFGogt+ASORegitZ6t7QOh/qyNqkVoclBduZWjyi9+Jztmn9hxHeOb8+qErsiVV
         uajfFYqkahYoTgDwYM8GC4o99wy0hykjatPped7B97EMOnHMmjC1GncMV4T9qTh5OKBB
         ZL96h8Y5kuwfNWENjU5pw9TOeFvOGqAYRRfAo7NOyGf92ENY+jIthbx9qTA9P6OCSGMf
         2Kvn5LCoPCF345lpzxXX8K+G52VdQRqUWdS4/R87INtOUSnb6FuT38WnfXDhMI9OluPx
         JrUmiJTOkKwwE+ukuiU3F0WDmfjrxmoDqG60bTmF8xqKmcgoK18CJIq6MM3rqEkHThLd
         Qdvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=KP43xD+XX6SI0WFbf9e1APdiupecxwiSqel5wwcHzyM=;
        b=CufaGhO/gLnetBM0heRwulX0Jro6aOKBJcjC/XhwdK3SQgPr0aDt/DD2HUfqCC0XCu
         3Mcp+SnGIVFmL3TYW5/zUxOELptBumS0FvCkWyxYcJIQoTgrmTyTTIiXTfD/w4i/9Kb5
         +oTfjCOfEwQABQxIahuWK8v3oRN/IyuaYNQeizfgzqnS+uyv55pQmQtSUBgap1Psvvzl
         JzLxuM+7xYuBCBcx//n/I7QUXoY3LbQLXatvte99thCtEf1xybGCiSQAomx8PmKRCMAw
         3AJWZj70eyBWH/vc+mTfst9Yd2Vs5otX8ARFUkR5jlHftPMIMy81pGC5TL64wnfcV+Ok
         5Jaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d12si1945730qkb.126.2019.04.18.14.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 14:07:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 76AD2307CB3B;
	Thu, 18 Apr 2019 21:07:12 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A564E60BE5;
	Thu, 18 Apr 2019 21:07:04 +0000 (UTC)
Date: Thu, 18 Apr 2019 17:07:02 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Peter Xu <peterx@redhat.com>
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
Message-ID: <20190418210702.GN3288@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190409060839.GE3389@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190409060839.GE3389@xz-x1>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 18 Apr 2019 21:07:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 02:08:39PM +0800, Peter Xu wrote:
> On Wed, Mar 20, 2019 at 10:06:14AM +0800, Peter Xu wrote:
> > This series implements initial write protection support for
> > userfaultfd.  Currently both shmem and hugetlbfs are not supported
> > yet, but only anonymous memory.  This is the 3nd version of it.
> > 
> > The latest code can also be found at:
> > 
> >   https://github.com/xzpeter/linux/tree/uffd-wp-merged
> > 
> > Note again that the first 5 patches in the series can be seen as
> > isolated work on page fault mechanism.  I would hope that they can be
> > considered to be reviewed/picked even earlier than the rest of the
> > series since it's even useful for existing userfaultfd MISSING case
> > [8].
> 
> Ping - any further comments for v3?  Is there any chance to have this
> series (or the first 5 patches) for 5.2?

Few issues left, sorry for taking so long to get to review, sometimes
it goes to the bottom of my stack.

I am guessing this should be merge through Andrew ? Unless Andrea have
a tree for userfaultfd (i am not following all that closely).

From my point of view it almost all look good. I sent review before
this email. Maybe we need some review from x86 folks on the x86 arch
changes for the feature ?

Cheers,
Jérôme


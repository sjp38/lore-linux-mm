Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32BD9C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 09:09:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF1B52077B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 09:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF1B52077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85C1C8E00F6; Fri, 22 Feb 2019 04:09:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 808E88E00F5; Fri, 22 Feb 2019 04:09:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D01B8E00F6; Fri, 22 Feb 2019 04:09:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FE528E00F5
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 04:09:33 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id o56so21934qto.9
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 01:09:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=xJ9QstaWGUYB7wh0PkerBPXIWY4WPA5W+woR1QhqhmY=;
        b=KUWTN+CJE9DLWBst6gBurAKeZWdtrrqZywOx1saHXgQ3iaQDn756EEBEiNumAEttlQ
         0/OqlWVLC063REFdLJkK1qOTV3zMJw6vuhBZxaucwcX8Zi66dRcYJV2Fy6Up4BGTgaef
         h9f1glVNGrpwCzV9BcbVEcUnU5nWW7iQj9wMnE7Ll/ogPzJnB609enLrfjdUjSovcBd7
         B/HhGdrgI+JuX/dFH1UzCQSYxbyVIUL4DLRTODTEk7RfjUyxof8ACAltLk3kQlgBiiZQ
         zfijGg/P1geK/Iz0i5FEFTURdXu1bsTkq0xCV1Cy5N39b2V7a/MdcuWgBSNXKWmuWqMx
         5qNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY4YX6A3HdReKkZ1x0+JBi33SNwtNnEa/nFUB5/r6KZkD5yphSQ
	c8kuzGIQjk+y9GJnxXHuiqaynb7RL93N6N7QCMmGh0RX912V3JXlO59Gzan9ocKncqi7TjPcmYD
	bX8h72gt/l4ReWL17Dk2VvY/gjT7zcekGZUD4iYEQpHJ690KdgqSWqmBFtOI6WoIPDg==
X-Received: by 2002:a37:ea1b:: with SMTP id t27mr2202333qkj.117.1550826573031;
        Fri, 22 Feb 2019 01:09:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY6Odcs7qnVAS2BK2n04/3XPVB0Y50jAby1KIjPBZdU1zKvRkxKy62DXRLNxmZ54pyBW2zN
X-Received: by 2002:a37:ea1b:: with SMTP id t27mr2202306qkj.117.1550826572409;
        Fri, 22 Feb 2019 01:09:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550826572; cv=none;
        d=google.com; s=arc-20160816;
        b=AkSDsqTagTi1PsipAXVl4KK6R1xlmSV/uy7gTBTsgniaObNoVv8YsITkK5NlGXJoOv
         3F9dzPZARGHVh0XfZrL4VXTvZUQSoC0yU++mjjX9dpGpCl9FQgTZOV12coUpkCnql9UQ
         bv7Cnr99Qb3oUV3y0+Y2IqzxpvnGY92lOloNjHMWgiz9A1s5xjtukVV6ipeSuZMVcaQK
         w+mIggnYKm8y8NmnJwhnUERtJZh1A14oYhiPDLSA5NopFMBtwZrWLXoxxJ/kofb+cViS
         bymR4Eka3W65i5c0MYeBvAUqXagQvixAjZx+avIOJu6/skulbC+43/AN2b0154D+G3em
         dC9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=xJ9QstaWGUYB7wh0PkerBPXIWY4WPA5W+woR1QhqhmY=;
        b=vCo1j773xN/LOrqJvrzTORQGB9KbHnRtjaieH3KM6doQt2TGfQ/EbS5zr35p+AcAHa
         ouCY6eEiWPTjyHLSnkOQnzs7yu/ORmdcnnqa2Pb4X2QoFzv1yAD6qwiymy8Ariy+4sg7
         EyJZyh6MRwAVsJCBey0TScTkbK8oVjTK1Qo53Y0qqZHwrqFsD/5S1TxQWO1u851LloSk
         ZdE3vU4Vrygk43bNyszyCWR8FX0u5zs/Nbw1w5OGxKAyhblzjgi54uw7DVqtL6p3EQkd
         556TlrLqtDeMFJ8PEs0f6DRl98WyXfmugXHAfSI1WFiNIv8SmKenE8pBP1TH7n/Vjl7p
         bCcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a46si605375qte.37.2019.02.22.01.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 01:09:32 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 592D9C04BD35;
	Fri, 22 Feb 2019 09:09:31 +0000 (UTC)
Received: from xz-x1 (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 96832600C2;
	Fri, 22 Feb 2019 09:09:22 +0000 (UTC)
Date: Fri, 22 Feb 2019 17:09:19 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 15/26] userfaultfd: wp: drop _PAGE_UFFD_WP properly
 when fork
Message-ID: <20190222090919.GM8904@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-16-peterx@redhat.com>
 <20190221180631.GO2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221180631.GO2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 22 Feb 2019 09:09:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:06:31PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:21AM +0800, Peter Xu wrote:
> > UFFD_EVENT_FORK support for uffd-wp should be already there, except
> > that we should clean the uffd-wp bit if uffd fork event is not
> > enabled.  Detect that to avoid _PAGE_UFFD_WP being set even if the VMA
> > is not being tracked by VM_UFFD_WP.  Do this for both small PTEs and
> > huge PMDs.
> > 
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> This patch must be earlier in the serie, before the patch that introduce
> the userfaultfd API so that bisect can not end up on version where this
> can happen.

Yes it should be now? Since the API will be introduced until patch
21/26 ("userfaultfd: wp: add the writeprotect API to userfaultfd
ioctl").

> 
> Otherwise the patch itself is:
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Unless I found anything I've missed above... I'll temporarily pick
this R-b for now then.

Thanks,

-- 
Peter Xu


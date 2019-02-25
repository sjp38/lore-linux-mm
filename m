Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C6CBC43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD2A420842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 08:31:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD2A420842
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 802018E016A; Mon, 25 Feb 2019 03:31:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7D90E8E0167; Mon, 25 Feb 2019 03:31:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A0278E016A; Mon, 25 Feb 2019 03:31:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC348E0167
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 03:31:26 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id u13so6231131qkj.13
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 00:31:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=atGQmtupU6nlpjHZc0m+Lwf2CL2z75ksS8zDV1zMbVg=;
        b=N3nHo/RK4ZNYkwPvKc/ClTYwRelMSfycwItV6UbAQGzkh3XGjvKUCYZ0SQ2ZbqvvNT
         GXf/5dIxpT2VdzArsrdGoMPWxrOd0ey8oLRPS+1JyP33R/WihD9sF++qs+T4PpkcXBU3
         nXQO46TzjmdwituPY1HwTl5peH2dtlAQJTfPJCwo2eC8TkEcTUu1GyHUyTwzD6TZUuV+
         E6sR271CZBr0kB5aoRmHxi9XYTIfsdtfCTd/ifzpPcCOZX0o+i1FmJwe5UJT7Vj/R8dH
         xuDeEW5yKGyzp6I4S5QDG9wIBJ3h6hSSSNaxIy5x+zUeDt7KgQ7jV5eFYNFLxHPBlJw6
         KbOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZHTEzgA383PRNOLYFtho0LynJxExsROIhrmIeq9RMK3MN4iMfI
	AvcgJN8rTalLT/uR9a05f4+P4R7kRLD3+50p2hdxpZswcznyCAX4V4cl3BBtxizH4tHlcFlmP93
	4E1WSL8O7rQayRHFmLrvAJvsWC80qKqWMcKCB6rINnSResKJugjl+cHOTMdYlgrZMdQ==
X-Received: by 2002:a0c:b00e:: with SMTP id k14mr12948486qvc.135.1551083485991;
        Mon, 25 Feb 2019 00:31:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2V1oQgE8lgTaKseyAeLg6ie25MRVkuMX+wJr2gBBPzMF5Y11DtEfniOwMuzAAnHSI4xQo
X-Received: by 2002:a0c:b00e:: with SMTP id k14mr12948456qvc.135.1551083485371;
        Mon, 25 Feb 2019 00:31:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551083485; cv=none;
        d=google.com; s=arc-20160816;
        b=r/hs7ZG2ZKebXI2NTMJOHhvz+CEgRTvWl+2ZxcUakJfiQ9tyjlpcwRmQILsiw0hba+
         2cnxchdRft6SBI+6HQwkxx+yDQ8NPNwDjuljz+a6a2aYE8gNG1KDiEHCPty9q0iBfED0
         gLibe1F+IavSh+h28Zm/0+h5yiaCWgnIqfSoMpzKrZvaZN5v9t+XG0OOgXeOD8kvthGV
         SYWb2yxnZ/mVMVSVLpotKvtS+526SAeeccut2YJnm3FWV89gIsb1rqc2aQkyXhAgmEoE
         gxEdxeR6PhC08Yp9iX6lgOzY5T+kCAucXUvDNM1kslL2OygkPqa7JTD7Cx0a3JAKwlRJ
         CacQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=atGQmtupU6nlpjHZc0m+Lwf2CL2z75ksS8zDV1zMbVg=;
        b=o47uUcsSw70WFr9tHWpBIPW8bFtPB8SqgfOVDbynKjOOS/Tu+1vc7y2UqiEsmFcBdd
         ApiT69tmvl3xuztMvQw3+YocBuVwhD2doK/kkLpXy8YUh5dscVNIgadKaF9gueaSUmri
         cLsI40G3tUt4xvJgbPT6L06ojrL1xgLzKhyYymG6rckSMDgqR8WrykWteGqMyMnL8tnC
         Sz9zumtMUaY8Oct36p+ZD+favhV1MbRBfvzunhEWW5MKj5ZB2ts4mVM0lG8QOIVSAxJ0
         VQyjghA74p/LB7eOg89KpA9fC1kwTtnwFvLlmaVTArPhQ6BAkH4/c+LMBp54668WVCLP
         /6ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c1si3036596qkc.51.2019.02.25.00.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 00:31:25 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 418BB81DE0;
	Mon, 25 Feb 2019 08:31:24 +0000 (UTC)
Received: from xz-x1 (ovpn-12-105.pek2.redhat.com [10.72.12.105])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 0998660865;
	Mon, 25 Feb 2019 08:31:11 +0000 (UTC)
Date: Mon, 25 Feb 2019 16:31:09 +0800
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
Subject: Re: [PATCH v2 21/26] userfaultfd: wp: add the writeprotect API to
 userfaultfd ioctl
Message-ID: <20190225083109.GB13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-22-peterx@redhat.com>
 <20190221182825.GA4198@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221182825.GA4198@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 25 Feb 2019 08:31:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 01:28:25PM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:27AM +0800, Peter Xu wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > v1: From: Shaohua Li <shli@fb.com>
> > 
> > v2: cleanups, remove a branch.
> > 
> > [peterx writes up the commit message, as below...]
> > 
> > This patch introduces the new uffd-wp APIs for userspace.
> > 
> > Firstly, we'll allow to do UFFDIO_REGISTER with write protection
> > tracking using the new UFFDIO_REGISTER_MODE_WP flag.  Note that this
> > flag can co-exist with the existing UFFDIO_REGISTER_MODE_MISSING, in
> > which case the userspace program can not only resolve missing page
> > faults, and at the same time tracking page data changes along the way.
> > 
> > Secondly, we introduced the new UFFDIO_WRITEPROTECT API to do page
> > level write protection tracking.  Note that we will need to register
> > the memory region with UFFDIO_REGISTER_MODE_WP before that.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > [peterx: remove useless block, write commit message, check against
> >  VM_MAYWRITE rather than VM_WRITE when register]
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> I am not an expert with userfaultfd code but it looks good to me so:
> 
> Also see my question down below, just a minor one.
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> > ---
> >  fs/userfaultfd.c                 | 82 +++++++++++++++++++++++++-------
> >  include/uapi/linux/userfaultfd.h | 11 +++++
> >  2 files changed, 77 insertions(+), 16 deletions(-)
> > 
> 
> [...]
> 
> > diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
> > index 297cb044c03f..1b977a7a4435 100644
> > --- a/include/uapi/linux/userfaultfd.h
> > +++ b/include/uapi/linux/userfaultfd.h
> > @@ -52,6 +52,7 @@
> >  #define _UFFDIO_WAKE			(0x02)
> >  #define _UFFDIO_COPY			(0x03)
> >  #define _UFFDIO_ZEROPAGE		(0x04)
> > +#define _UFFDIO_WRITEPROTECT		(0x06)
> >  #define _UFFDIO_API			(0x3F)
> 
> What did happen to ioctl 0x05 ? :)

It simply because it was 0x06 in Andrea's tree. :-)

https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=ad0c3bec9897d8c8617ecaeb3110d3bdf884b15c

Andrea introduced _UFFDIO_REMAP first in his original work which took
0x05 (hmm... not really the "very" original, but the one after
Shaohua's work) then _UFFDIO_WRITEPROTECT which took 0x06.  I'm afraid
there's already userspace programs that have linked with that tree and
the numbers (I believe LLNL and umap is one of them, people may not
start to use it very seriesly but still they can be distributed and
start doing some real work...).  I'm using the same number here
considering that it might be good to simply even don't break any of
the experimental programs if it's easy to achieve (for either existing
uffd-wp but also the new remap interface users if there is), after all
these numbers are really adhoc for us.  If anyone doesn't like this I
can for sure switch to 0x05 again if that looks cuter.

Thanks,

-- 
Peter Xu


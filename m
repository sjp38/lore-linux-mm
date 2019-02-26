Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1C52C10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:43:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 885632173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 07:43:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 885632173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0932C8E0003; Tue, 26 Feb 2019 02:43:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 069F98E0002; Tue, 26 Feb 2019 02:43:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC2D08E0003; Tue, 26 Feb 2019 02:43:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id C37BC8E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 02:43:09 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id j1so4919934qkl.23
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:43:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CqzUShwxt/jWrbsehbRcPI2WNcNAj1RDj7UxdX3XAM4=;
        b=aw6D33o+StA2AL2j2u9qrVdp8lK1lfxqEdmlnNRwtMLANOZoXLDSmVKILjN8p3H8ut
         kXpKQMUoxkmBtO81nhANAMwNv2R/73yKMAN6cOjQI8HHL6qYkmpstO8nqbVmPXJJ9tcj
         tAn+l5IshvaOii9TQv0gNAQ9dxgaykx+eSTW4wLI3I6A+sA07KJwBw0nR6/0C7Vn7wHE
         VpdDEYz5BxAA1aPsuTsUiAuD9s+x9Wz5UR6hy7D48GWZdNSxdwj3WDy1w3sQO7O/Omxr
         EI7WrIv1oD/yrgrS5WZ1TOExpKImUWFbuDjPAplqPzZTR5VEFkJamfk1BkQELdNJsA9C
         GEEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaEFBPivxMXNLhXCfEG3/JA0o3zDCiE3n9/GyKW8eWf07fAHvNC
	4E7jcnnfUdY2TP5MKBsm+UY6FAnZo/L1jDQKUKVIOuPFAbJEsclp05mJHSiMpcKt52NZrbcEx4y
	ESjKSYnl+jjnx3IyiMYekxitEGrHlGBokviv4GpJLy6dQt/vjfcNB5BTnHK+nHFd4kA==
X-Received: by 2002:ac8:34b2:: with SMTP id w47mr17290882qtb.112.1551166989593;
        Mon, 25 Feb 2019 23:43:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY0/J9B6r4+cJweBjEAhEKm6WyVqVhgomuwhvlrsoGws0RLNkibCVtut2MeM2beMiT7syUY
X-Received: by 2002:ac8:34b2:: with SMTP id w47mr17290868qtb.112.1551166989049;
        Mon, 25 Feb 2019 23:43:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551166989; cv=none;
        d=google.com; s=arc-20160816;
        b=mcywvtesAsbPzon0SRzVwOi374eo3xCWQrvk5npuf0HbYJdWoR7btRVN0PTmyclFc8
         tyw0INeA6LiIORiTLiA17xJNf3sDeu4kHj2Bt2SaWmPQXEkg+fMUO6pvfvK+fnfXaq22
         K1lklsZaT5mXXdQrCvqipdKROel1/NigYrVlPlp1KRFnhSgkm18YrzQpGXyAPg5RbpVU
         fnv/pi3zNVfAswdIBrOW20CbXASrQfIkoXEiHNdV9UEgHZbX/oLjVx5VTNLbg7CV7vSz
         bp8sKejN7U5Rf4BebARCjqeskk5ourXo2ysxVCetMw2jrqvJDdTXuYrVc5TiDKb4uN+V
         slBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CqzUShwxt/jWrbsehbRcPI2WNcNAj1RDj7UxdX3XAM4=;
        b=Rd6HkR+ZGr9QdWWhAFmpPl9pcTi2vKkKUwUGooriknAgeYO3UgT9aEZCJGehQ7hncR
         JeUQ+azZznwZksQ5JzKriwSzCSEzVz4E/AQl9tzAqUNa/hhOsu7POExNXOgdqltYHoZk
         vjzaYsJ7ziAeSIt90LH5Vi6GUxK7o7da5jHm1ZWxHZ7X7iI5VrMaXbbmYJOeHJI1bBVO
         KZ2NLPwSEix2sUw7hRIRGdHrEnnlTkQnu/g4Lrg5Lak74zMy4mvsUnnoDw5r4FSlEqZP
         rh8GQTVr2yFmZUEh4drgJHXJR97GjjZo7t1dAIp5BXU/IGqXru+OIoWxlF60/M131cfC
         2P9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si3317792qkk.89.2019.02.25.23.43.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 23:43:09 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1CE1F8666B;
	Tue, 26 Feb 2019 07:43:08 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C3B585D9CC;
	Tue, 26 Feb 2019 07:42:59 +0000 (UTC)
Date: Tue, 26 Feb 2019 15:42:57 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
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
Subject: Re: [PATCH v2 24/26] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP
 documentation update
Message-ID: <20190226074257.GM13653@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-25-peterx@redhat.com>
 <20190225211930.GG10454@rapoport-lnx>
 <20190226065342.GJ13653@xz-x1>
 <20190226070307.GE5873@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190226070307.GE5873@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 26 Feb 2019 07:43:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 09:04:25AM +0200, Mike Rapoport wrote:
> On Tue, Feb 26, 2019 at 02:53:42PM +0800, Peter Xu wrote:
> > On Mon, Feb 25, 2019 at 11:19:32PM +0200, Mike Rapoport wrote:
> > > On Tue, Feb 12, 2019 at 10:56:30AM +0800, Peter Xu wrote:
> > > > From: Martin Cracauer <cracauer@cons.org>
> > > > 
> > > > Adds documentation about the write protection support.
> > > > 
> > > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > > [peterx: rewrite in rst format; fixups here and there]
> > > > Signed-off-by: Peter Xu <peterx@redhat.com>
> > > 
> > > Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
> > > 
> > > Peter, can you please also update the man pages (1, 2)?
> > > 
> > > [1] http://man7.org/linux/man-pages/man2/userfaultfd.2.html
> > > [2] http://man7.org/linux/man-pages/man2/ioctl_userfaultfd.2.html
> > 
> > Sure.  Should I post the man patches after the kernel part is merged?
> 
> Yep, once we know for sure what's the API kernel will expose.

I see, thanks.  Then I'll probably wait until the series got merged to
be safe since so far we still have discussion on the interfaces
(especially the DONTWAKE flags).

-- 
Peter Xu


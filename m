Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E2D3C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:55:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21EB821019
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 23:55:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21EB821019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862808E0011; Wed, 13 Mar 2019 19:55:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 813258E0001; Wed, 13 Mar 2019 19:55:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 727EA8E0011; Wed, 13 Mar 2019 19:55:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 516AF8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 19:55:42 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id f15so3624311qtk.16
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 16:55:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hOAXqP5LQkSbG+WT0L6GK0CduMk0ul92znI8AELgRHI=;
        b=benz6JPmfK24ha+HkdyhdUswH8dvZ2DHsTpJSJzHIVbEwkFh/1GVxa0afev1Lv8Rdk
         YfctfdHAmF/SVzw9mkZyH+t5fyzO88geKlDQvencOrQqF0WY3kmNbcLKHnOYqztJrkpb
         nx0I53eZB47+olH2H9RiAX6MgWESvIZfMmSotnIXybX7AbwGT/CKoYeKxZdOJhYjvfj7
         WLe0wyCfOqM4Gzl+WKnSgqpygHEPUD7tbcCxYqowOsQ/e0R/I45VcvFmaAryRja55hnf
         dozkvVeiwS8bRmcSwray+XekAosCndCybl3uX2o986fuPvi/A/4UGDLljhUL8kWuN9Jk
         Lf8A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVsw8iNc8IjvN8eq3XyykJe4E2NZN2SZEr55ES5Atx1CuJcqkC2
	q/lT9kc7A0ypOwADkiCPLCRLtIOS0E0vWz+EKwXmn2wph5VQBOKNgm8raB70mQv0trQR2OJsi2t
	dgjS+eas8mdWExuktq98ylCYNV1QG3B0gi5vfpX+eEmuaSplTNiHLykcHdNhyjvboxg==
X-Received: by 2002:ae9:eb41:: with SMTP id b62mr11885580qkg.309.1552521342026;
        Wed, 13 Mar 2019 16:55:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz+BglAtXdyytEHX3katYdwfxgVBsWuSmUeNAHn46x899ejiu5O/PBtfybFfhZRx+1fBiA
X-Received: by 2002:ae9:eb41:: with SMTP id b62mr11885551qkg.309.1552521341271;
        Wed, 13 Mar 2019 16:55:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552521341; cv=none;
        d=google.com; s=arc-20160816;
        b=COVgcAantAR+CbT9YYcQ9CNh/wvx4YCW8GfE9OQGwkw9n4lJfmx9RkFWwtiHDW+Hgv
         VAFNSJalmSOrduOxg5p1kqqxC1zxpZDIFCS4ZaMBIdJCJ6Vv9PM8hvQJ0/E09jAXBZxt
         7nQHB++7y7XkTXLqcTCKIjX/9UZSjMWBBcAA6gwzb80AbHu6v5OzDU1RiatZp+IEYY3l
         nyyC0vxE5y5Nyr4PLcol5QmuIZqfd+/gUGlEzGsaWFkEN2Ar3Y1tmkd3kUOTQTMQGNfC
         VBJS5G370hsY+cN9kNAmO/ijp4XCGUPn6rTWPl5TKHJtqieqGm6AuAM74SnWY4sC24s6
         C13Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hOAXqP5LQkSbG+WT0L6GK0CduMk0ul92znI8AELgRHI=;
        b=br7F3Fr0SXYDPlI4NKk0QvcAELNWLIcXwJ+KdiEpO6KoKXf38LvZZqRIz23nf7x7In
         Ew9VkmT/2IhszxBCUZ2M0pElwtsNuPOw2kxzIM2Pf9Q8zqpP0l0L1No4IPwgA9A+5Ekd
         /Set2N3lhzagZwv0LthJzyMAKTOQABrtTDNkc+gOao4R8Ah85+YIZDiorbci9gbWRloC
         4ZpcNErvnWr5kEIcyhSYv9r7tnro7K3RNpqekzzrwp3QsEVmD43UvXvdU4jYN/uKAESQ
         xFvIbvKy1BPclA+S2g5PH6GbYwvvn9hwR970IXbqTT+QP8F+ydqoBfrhVztrx0BHzf1/
         BYvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b9si5674962qtb.85.2019.03.13.16.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 16:55:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 49E6730018EB;
	Wed, 13 Mar 2019 23:55:40 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8461F60F94;
	Wed, 13 Mar 2019 23:55:35 +0000 (UTC)
Date: Wed, 13 Mar 2019 19:55:34 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>, Peter Xu <peterx@redhat.com>,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190313235534.GK25147@redhat.com>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <3714d120-64e3-702e-6eef-4ef253bdb66d@redhat.com>
 <20190313185230.GH25147@redhat.com>
 <e1fcdd99-20d3-c161-8a05-b98b8036137c@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e1fcdd99-20d3-c161-8a05-b98b8036137c@oracle.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Wed, 13 Mar 2019 23:55:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 01:01:40PM -0700, Mike Kravetz wrote:
> On 3/13/19 11:52 AM, Andrea Arcangeli wrote:
> > 
> > hugetlbfs is more complicated to detect, because even if you inherit
> > it from fork(), the services that mounts the fs may be in a different
> > container than the one that Oracle that uses userfaultfd later on down
> > the road from a different context. And I don't think it would be ok to
> > allow running userfaultfd just because you can open a file in an
> > hugetlbfs file system. With /dev/kvm it's a bit different, that's
> > chmod o-r by default.. no luser should be able to open it.
> > 
> > Unless somebody suggests a consistent way to make hugetlbfs "just
> > work" (like we could achieve clean with CRIU and KVM), I think Oracle
> > will need a one liner change in the Oracle setup to echo into that
> > file in addition of running the hugetlbfs mount.
> 
> I think you are suggesting the DB setup process enable uffd for all users.
> Correct?

Yes. In addition of the hugetlbfs setup, various apps requires to also
increase fs.inotify.max_user_watches or file-max and other tweaks,
this would be one of those tweaks.

> This may be too simple, and I don't really like group access, but how about
> just defining a uffd group?  If you are in the group you can make uffd
> system calls.

Everything is possible, I'm just afraid it gets too complex.

So you suggest to echo a gid into the file?


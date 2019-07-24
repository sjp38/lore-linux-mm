Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7A62C76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:25:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B92DB21951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 18:25:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B92DB21951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 479316B000E; Wed, 24 Jul 2019 14:25:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42A878E000B; Wed, 24 Jul 2019 14:25:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 31A668E0007; Wed, 24 Jul 2019 14:25:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14A286B000E
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 14:25:26 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id m198so40009396qke.22
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 11:25:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=/8SpAXACt/H0ZjS+gW4ox0Hhxo1Ofk7o0k1709Jn7z0=;
        b=ZG3U0oH/oZ7b2V8WCXPdSNgiYxx9BKPtwu2vV1uDQ0jBHEuk2XiAONiPhBysdFVqdx
         fChKF5JzgGYN3Atc+wHkzyerT0Lz6Vco5Ln57E0t6mCjOp22/0OZppZJ+Jh8v9DmTEmq
         qY6zMASpvPyVaDtdfBNBKn3vrRbothn19WoKxi3I19crEw+M6RNaUAxpRW9JKu5l8oTn
         0oPTcwbSx6XfvwIlD/6r9xvvozkAjkHK8LtCIQKbVo0Jge18FuW6/3upNEBcU+EAwroi
         Dq+zWDFp358ftIn2Xetxqmi5KGUVd2YctCp9lA+J7sBp8LtpEKqWGpLwVK8DlMhGPHay
         xLbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAViCfbs3r/sljaufdbCfC9BEOqJPOaU1OnySuuPgwyHNf9tj9VX
	nuTlL72+fTGtZL+SNqAr3VkhTWEQ8sHsx5GtqOo9yQxZinSXAKT4aVqfMX7looaNjzh5vz9mVVA
	tSWgMv08nLpmkIPJudodL83AID+GO38yJG/kgC2xFJQ5WfL3a7TcDZU+nyrhG+hQsjQ==
X-Received: by 2002:ac8:37b8:: with SMTP id d53mr57983199qtc.227.1563992725870;
        Wed, 24 Jul 2019 11:25:25 -0700 (PDT)
X-Received: by 2002:ac8:37b8:: with SMTP id d53mr57983150qtc.227.1563992725265;
        Wed, 24 Jul 2019 11:25:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563992725; cv=none;
        d=google.com; s=arc-20160816;
        b=pSnC7ENByFemgORJb+zVkokMP9Om5NSC1Me0BnNywn+OGYZCGQHgNq5JNqAVNInNXl
         U3vfza8TiZXJ0QcE+uoyhW4SFcA9aRdQbTURaVdTm0v1bjTwMj3g3FIJQrNeo9uEBGTT
         6t9+i3WzLz316+j9BxQwLqZ+rwBIUFQ33VCUewGGTGecANdmtM84WumsKzZuHLCVwE4Y
         xUvJvDN5yi8+7/MVESrJGdVmAO6ltS0Bnmjq5LXwMwE0qnQqimdelhmzFI6+REcHhx76
         9aRu5gz4V7jvn3tLYDuyodR6uCaiIAOCequX/CIagyeB8PfOr5d/LSny1TfFEbU8yVbW
         sMSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=/8SpAXACt/H0ZjS+gW4ox0Hhxo1Ofk7o0k1709Jn7z0=;
        b=X4OlqOm3zuJkjPbRBJOvP7TvbyezvOQtyYM1Ts+VX/hEKHk78/MvXTkm8NFxNnU0ed
         OFeqC+l4VkulhnR/vehyJxE8fadXHbA3FwXErA9acpAKuOIrIKpbg2HlTDdUx7QQ+KYr
         lxY1/gdoYqmS/yUmtoMFyerotZwIr/2SsrcCdqqSU1qtxswBh8GNGnHPPcf/5Tm2HvG8
         pHNnsh3uSmG0yNufC7vYgxSXmgT8ndppmmU8vWhlwPdeWKoZZqvqnwnGcEJKzX0hmEpk
         eifux/m4pPWa3D+rTao1x7Xv8I6yuKCkQzJzVwkqd0UfdntXLQJfIwA+6wcf2XsqyIRR
         oNbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y8sor62629645qtm.63.2019.07.24.11.25.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 11:25:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxChd/0aII9lYKOFDT2kMgtEOZZfG9pHDvB+TKQrkk+gyvE7N4AF8TKeYtvP4hnErvwYvbJPQ==
X-Received: by 2002:ac8:74cb:: with SMTP id j11mr54557383qtr.67.1563992725087;
        Wed, 24 Jul 2019 11:25:25 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id z19sm22080696qkg.28.2019.07.24.11.25.18
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 24 Jul 2019 11:25:24 -0700 (PDT)
Date: Wed, 24 Jul 2019 14:25:15 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Jason Wang <jasowang@redhat.com>,
	syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
	aarcange@redhat.com, akpm@linux-foundation.org,
	christian@brauner.io, davem@davemloft.net, ebiederm@xmission.com,
	elena.reshetova@intel.com, guro@fb.com, hch@infradead.org,
	james.bottomley@hansenpartnership.com, jglisse@redhat.com,
	keescook@chromium.org, ldv@altlinux.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, linux-parisc@vger.kernel.org,
	luto@amacapital.net, mhocko@suse.com, mingo@kernel.org,
	namit@vmware.com, peterz@infradead.org,
	syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk,
	wad@chromium.org
Subject: Re: WARNING in __mmdrop
Message-ID: <20190724142417-mutt-send-email-mst@kernel.org>
References: <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
 <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
 <20190723110219-mutt-send-email-mst@kernel.org>
 <e0c91b89-d1e8-9831-00fe-23fe92d79fa2@redhat.com>
 <20190724040238-mutt-send-email-mst@kernel.org>
 <20190724165317.GD28493@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724165317.GD28493@ziepe.ca>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jul 24, 2019 at 01:53:17PM -0300, Jason Gunthorpe wrote:
> On Wed, Jul 24, 2019 at 04:05:17AM -0400, Michael S. Tsirkin wrote:
> > On Wed, Jul 24, 2019 at 10:17:14AM +0800, Jason Wang wrote:
> > > So even PTE is read speculatively before reading invalidate_count (only in
> > > the case of invalidate_count is zero). The spinlock has guaranteed that we
> > > won't read any stale PTEs.
> > 
> > I'm sorry I just do not get the argument.
> > If you want to order two reads you need an smp_rmb
> > or stronger between them executed on the same CPU.
> 
> No, that is only for unlocked algorithms.
> 
> In this case the spinlock provides all the 'or stronger' ordering
> required.
> 
> For invalidate_count going 0->1 the spin_lock ensures that any
> following PTE update during invalidation does not order before the
> spin_lock()
> 
> While holding the lock and observing 1 in invalidate_count the PTE
> values might be changing, but are ignored. C's rules about sequencing
> make this safe.
> 
> For invalidate_count going 1->0 the spin_unlock ensures that any
> preceeding PTE update during invalidation does not order after the
> spin_unlock
> 
> While holding the lock and observing 0 in invalidating_count the PTE
> values cannot be changing.
> 
> Jason

Oh right. So prefetch holds the spinlock the whole time.
Sorry about the noise.

-- 
MST


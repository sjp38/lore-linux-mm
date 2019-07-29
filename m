Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92020C7618B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E8CE2070D
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 08:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E8CE2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF47D8E0005; Mon, 29 Jul 2019 04:59:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA5BB8E0002; Mon, 29 Jul 2019 04:59:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D92CF8E0005; Mon, 29 Jul 2019 04:59:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B93198E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 04:59:38 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s9so54523014qtn.14
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:59:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=Q68Dj7R63I2Ecvb2PPGzHjYhrCQecwVv+3ZzbHMtRrM=;
        b=ZlmMuvm8vmyVQLAN15qq8hvh8HXUgazTPU8qGrlpiDm95jdHiyOSEejLrU44X1ZtUN
         uMgieCRJsEceosA//Hd/g59V24hi+tBZPeRjDb86Wi69Coc9oNeFzYtJUBVaMa/YbW2o
         WhuofzWMseGJGFGO0kvKEn6vKwygR7fQsXzUQfEpupBWrVLFgb+3UFUPPhvR7yeEJ9Z/
         1WKhXnECTHhl+t3DJQiGxO0aIDZZyqsCqaPiuplyoi4qdC0PXClunIrIV/LseNUN6NMT
         FVLV3Dsa//VV7IN+kBjle1ieXIhmfQwBsOPfU9RQTKsMb11PrBh/85GtgThvtyzPEmCP
         FeBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWfd6xpBX1DQRzYSPBVCzUPQ+mpFgJOmQAKVSi0VeNpuSv343Kd
	3jeZK5BOCygcRZ9SGrTEhCo0vQOFwNRImIYD/gqJmB4BWWOFoyiIJkIZSbnnk4nsJm6U0vi0rvb
	btKmbaP4XvNr+kMqpQOvRYxofLnKzI9dYyQhZHGGMjrjWXNw5ks36oL03xJNtoxXKFw==
X-Received: by 2002:ac8:4758:: with SMTP id k24mr75871906qtp.20.1564390778526;
        Mon, 29 Jul 2019 01:59:38 -0700 (PDT)
X-Received: by 2002:ac8:4758:: with SMTP id k24mr75871874qtp.20.1564390777823;
        Mon, 29 Jul 2019 01:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564390777; cv=none;
        d=google.com; s=arc-20160816;
        b=uoURPIhJmSx7JpCygmxVXxqlY+4+j4L5zWz2Udz074ALvdt3E6OutVjj02JH/RCuuc
         Tje7uhymf15XvzZuTm8LDW0QseftDt0ig653bJgM4jpaEx8+tLWq3fV4qpZrexXNyaBl
         7dFxbGFvyxrzTZndbnek0I4bOAri5KsKgO7Sr4Mf5CqjPCXcj0SvLG02iIvN/1xgGU3T
         xYEP1kQPFfmxpVIMkAQSs+DmlL7vvfuGljR+NyIAiFTIrjaqyMXyTHo5bR4GPOW8bQax
         z3ABKm0PfAVQ8s2jlXNrBxWfSJ3lvLeOuaJkWpvIgvDc7EZvSnroclQuVZGOwouuNioZ
         en0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=Q68Dj7R63I2Ecvb2PPGzHjYhrCQecwVv+3ZzbHMtRrM=;
        b=LRgeDPcEWnPaNC0FzZCk6bFzBf+hqWkwayuPA891UxM+OdtrAfqH63Iaf0YPjEBxqW
         YbWDIYiaHp9qsTOs4LKuVS1qon9+eDq9PKv2jYM/qcVc35pEfqlvnE+gvUgQyzfKl675
         7+1rmtyikyEbhYmE8q2oabnwNhg4nB3BqjIJBfcoAxipFzEOxEsKB+bYXxxGA84OIyI8
         wVBj0M/Z3ib4QVTU5LS55MPlCCQw2hR6m9p+2KsH237fl9FitzS2KteQSalC5PyaXXiD
         X6gEF7IpLEKTdoSwt1oNHc8le2kgucQCFxgDCcy7j84PU91l93MUcnzEL6/34k7MrZG/
         breQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x19sor79781849qtq.45.2019.07.29.01.59.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 01:59:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzdpBbLibFicHdiT5TefWqFoQxYcTCr3KhKgWnun67P5z4zFpu5Vd0tQv7j2SaN95sYflY5Ng==
X-Received: by 2002:aed:39e7:: with SMTP id m94mr80555924qte.0.1564390777624;
        Mon, 29 Jul 2019 01:59:37 -0700 (PDT)
Received: from redhat.com (bzq-79-181-91-42.red.bezeqint.net. [79.181.91.42])
        by smtp.gmail.com with ESMTPSA id z1sm27810714qke.122.2019.07.29.01.59.30
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 01:59:36 -0700 (PDT)
Date: Mon, 29 Jul 2019 04:59:27 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
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
Message-ID: <20190729045127-mutt-send-email-mst@kernel.org>
References: <84bb2e31-0606-adff-cf2a-e1878225a847@redhat.com>
 <20190725092332-mutt-send-email-mst@kernel.org>
 <11802a8a-ce41-f427-63d5-b6a4cf96bb3f@redhat.com>
 <20190726074644-mutt-send-email-mst@kernel.org>
 <5cc94f15-b229-a290-55f3-8295266edb2b@redhat.com>
 <20190726082837-mutt-send-email-mst@kernel.org>
 <ada10dc9-6cab-e189-5289-6f9d3ff8fed2@redhat.com>
 <aaefa93e-a0de-1c55-feb0-509c87aae1f3@redhat.com>
 <20190726094756-mutt-send-email-mst@kernel.org>
 <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <0792ee09-b4b7-673c-2251-e5e0ce0fbe32@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 01:54:49PM +0800, Jason Wang wrote:
> 
> On 2019/7/26 下午9:49, Michael S. Tsirkin wrote:
> > > > Ok, let me retry if necessary (but I do remember I end up with deadlocks
> > > > last try).
> > > Ok, I play a little with this. And it works so far. Will do more testing
> > > tomorrow.
> > > 
> > > One reason could be I switch to use get_user_pages_fast() to
> > > __get_user_pages_fast() which doesn't need mmap_sem.
> > > 
> > > Thanks
> > OK that sounds good. If we also set a flag to make
> > vhost_exceeds_weight exit, then I think it will be all good.
> 
> 
> After some experiments, I came up two methods:
> 
> 1) switch to use vq->mutex, then we must take the vq lock during range
> checking (but I don't see obvious slowdown for 16vcpus + 16queues). Setting
> flags during weight check should work but it still can't address the worst
> case: wait for the page to be swapped in. Is this acceptable?
> 
> 2) using current RCU but replace synchronize_rcu() with vhost_work_flush().
> The worst case is the same as 1) but we can check range without holding any
> locks.
> 
> Which one did you prefer?
> 
> Thanks

I would rather we start with 1 and switch to 2 after we
can show some gain.

But the worst case needs to be addressed.  How about sending a signal to
the vhost thread?  We will need to fix up error handling (I think that
at the moment it will error out in that case, handling this as EFAULT -
and we don't want to drop packets if we can help it, and surely not
enter any error states.  In particular it might be especially tricky if
we wrote into userspace memory and are now trying to log the write.
I guess we can disable the optimization if log is enabled?).

-- 
MST


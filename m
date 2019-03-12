Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEF56C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:04:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A827A206BA
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 20:04:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A827A206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 33C998E0003; Tue, 12 Mar 2019 16:04:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C5768E0002; Tue, 12 Mar 2019 16:04:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 166908E0003; Tue, 12 Mar 2019 16:04:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DAD048E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 16:04:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 35so3428682qtq.5
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 13:04:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=akxVDaqCkmLREnINvadIYFkfVvDbWfWA451PFdxqjq4=;
        b=Sx6Fs2IcmoK6y/mQhi+cA7hIgVP0Uz5N3HrK0sAeX44+o6bKXX/Xazs0sLGh6un322
         YEzBNvrORriqT531EArkhLnZghz2Ja3FNF9TPqB0FEvB67IxTMndgC6tcx8d1Ei3b+Mk
         2RFyLDCNkcF3MeL8Wbn4wI0BHj/iXXZjXWC/08rkU2drEpv/J4atlzmfJsFGtIKW3JfG
         2yOuOMx90c/fBdFDqlgAcbq4YpUdNkV2LsgGAEV+ttZ+5g+UtDVIQFXoUs8qRp/5tPUJ
         yZx/XkagYTiv43CSTRj5ii7O+zLduzpGyISqLxJobtX9FfE4J0eqU5oWTWhozWWa3FhQ
         Kqyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXtZJiqTHYZJ1oY/v+f7uOAJjlnq717jtebCwphNHidoKrkZ/DY
	TtuW5IVtNsipfjCjlEk1zbybdRQ3KyNX67T4+gkiXxBkvtV5e1etXShoNgxWDv7c0aYNh1KAJMm
	YQd5OhyHRsU/Vyy3vnmPU7roskqGUBbhQLFD6fgWVqaeweiyjzIz8jaV8egutrf0NxQ==
X-Received: by 2002:a37:68cc:: with SMTP id d195mr10128925qkc.131.1552421095656;
        Tue, 12 Mar 2019 13:04:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6wmDRQGX6xVSho1zIUXj+lOclSUUF/0dmZVSSDjJSlRExZEtB+/9YwHboD5xZtuxghW2c
X-Received: by 2002:a37:68cc:: with SMTP id d195mr10128870qkc.131.1552421094858;
        Tue, 12 Mar 2019 13:04:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552421094; cv=none;
        d=google.com; s=arc-20160816;
        b=YLGLXo+88b9KrG8JW75aql92bLIRI4gG46cxOX+u/TdXe4IAafkTPhDKOGrsEfGldV
         AR5lBVxwAedK/XqmnS3GhsCCLJDQbw3oEDzD21UPYzz/uaOkkwM1UJWDLRM3RpZx3bOL
         HrdCH3yga3C0eNnToJwgFbVw2AAUBHnVHDEz4wHVCmRZ0qWi9d2uEMnXV6ti6elcUo1D
         7M4kfL/lP/QtFYbidqFVVvcbpXiYYQnQqkS5bmd/Br80hnnqLspM6WlqJPK+1os1TngU
         WFrha9FIlFeiaR+WCYKtJxQb8q3RzAgQtxsj5nMnDAUVqBMyieb3j+uMBHYV1zWATdlA
         78pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=akxVDaqCkmLREnINvadIYFkfVvDbWfWA451PFdxqjq4=;
        b=GeV8+gkFz5UfAYe/kW12bo2aTfqmvSbN9V4pk/ZvthQ8h30JQWfJhhA3hT8BqhrI/w
         JG9RHHaelB1Cv2hKn2HPUFR04cP3hIG1sk4IsIddjp7iYforzSUIhysJ3W1PCms9BK+a
         jZfmj2A8x4HL2hHMMFpoi4JPh9I4+4eOqHXnA4u5Y4w62+9kxvJ2OcJsksish0fFYEUx
         +4AQ54LeEXhE1cj9LG2kcM9ID56quML47rSrDs5tSBI02RW4govXBi6m2gq3/CL22LKs
         ziJaNQ2+1QhLqgQVabzcR4fPfy/2KnChRccdLD+12GWIZPJlzLfBHE1nKkoedd8Spo6X
         RFhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v91si2069260qvv.54.2019.03.12.13.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 13:04:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C82453086203;
	Tue, 12 Mar 2019 20:04:53 +0000 (UTC)
Received: from sky.random (ovpn-121-1.rdu2.redhat.com [10.10.121.1])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 20E951001DFA;
	Tue, 12 Mar 2019 20:04:51 +0000 (UTC)
Date: Tue, 12 Mar 2019 16:04:50 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, Jason Wang <jasowang@redhat.com>,
	David Miller <davem@davemloft.net>, hch@infradead.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
Message-ID: <20190312200450.GA25147@redhat.com>
References: <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
 <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
 <20190312075033-mutt-send-email-mst@kernel.org>
 <1552405610.3083.17.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1552405610.3083.17.camel@HansenPartnership.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 12 Mar 2019 20:04:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 08:46:50AM -0700, James Bottomley wrote:
> On Tue, 2019-03-12 at 07:54 -0400, Michael S. Tsirkin wrote:
> > On Tue, Mar 12, 2019 at 03:17:00PM +0800, Jason Wang wrote:
> > > 
> > > On 2019/3/12 上午11:52, Michael S. Tsirkin wrote:
> > > > On Tue, Mar 12, 2019 at 10:59:09AM +0800, Jason Wang wrote:
> [...]
> > > At least for -stable, we need the flush?
> > > 
> > > 
> > > > Three atomic ops per bit is way to expensive.
> > > 
> > > 
> > > Yes.
> > > 
> > > Thanks
> > 
> > See James's reply - I stand corrected we do kunmap so no need to
> > flush.
> 
> Well, I said that's what we do on Parisc.  The cachetlb document
> definitely says if you alter the data between kmap and kunmap you are
> responsible for the flush.  It's just that flush_dcache_page() is a no-
> op on x86 so they never remember to add it and since it will crash
> parisc if you get it wrong we finally gave up trying to make them.
> 
> But that's the point: it is a no-op on your favourite architecture so
> it costs you nothing to add it.

Yes, the fact Parisc gave up and is doing it on kunmap is reasonable
approach for Parisc, but it doesn't move the needle as far as vhost
common code is concerned, because other archs don't flush any cache on
kunmap.

So either all other archs give up trying to optimize, or vhost still
has to call flush_dcache_page() after kunmap.

Which means after we fix vhost to add the flush_dcache_page after
kunmap, Parisc will get a double hit (but it also means Parisc was the
only one of those archs needed explicit cache flushes, where vhost
worked correctly so far.. so it kinds of proofs your point of giving
up being the safe choice).

Thanks,
Andrea


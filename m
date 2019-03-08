Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D79CC43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D087820661
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:59:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D087820661
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E8A18E0003; Fri,  8 Mar 2019 13:59:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 698428E0002; Fri,  8 Mar 2019 13:59:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5ADA28E0003; Fri,  8 Mar 2019 13:59:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 321958E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:59:09 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id v67so16751426qkl.22
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:59:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=13oWsy/a9o3RwpeIQWA/iT9VogWPwGVjX2GBI/RlvM8=;
        b=YMyLmgM/cuSQPwH9vqs4HPH9L5d7T7gDlMV4WWe494b3Q5OjKvY++mxdgVDvSZHoht
         cGxLNUjrlzmXWv3bPgB0MfitBBOqQSZ4P7QX72ULgtteEZ6cMEh0mTXRofnHN+XdU2x9
         IOC+H9rgo9XI3QC1v3dsolWFo1qSmtTg0KmpXDfZiQEd1V6O45clB11UMbjBSV6QIQbw
         22cbZJT0NqZ7e2MPTt80jK4ZhhkUAyzgHLwDgPhsKJZwrfxpKRJiaelTrS/yoaWvvpmx
         hJmCJwzDUTDJOC7sSb2z8hXzdAy7Sdquq6rGGa1yCqryYR+endOAWaQyBnMWvf/3soU0
         KLWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWdiV0onCfFjPyxkjtG9+F12uuUG9DOydTMuAzaZyJQ0IlkH+dS
	MLKqVHKKuNkEskEz5RMNp7pfDW0BLeMatGmUSEcPZE/88uqEy+G2evrewxjY+YA/nGbm2EsJ+Q+
	EkS53qTtNvA0jPz9tBq7cr0NXbIYUrLpi9f7+JVjBp61mXLgqEiUGXjKQq6jTk/rMbHIfF3nWli
	zZo5dFEk4mgv7Vx2T9UaCJk1dOjoEBOC/Hu3Ed79qJOsTpu1Q9o0/yEqkOMmtpqR77x1dWByOqA
	ab9YGO9qYSxnypmo+12ErBFXEUwm0hgPs5yAmRilFZG/DZgpGDwuK2Oa7BcEaMaqHf6PxooP/sK
	jMuahhse1qjLeF8td1Z78L/qJZLMOSqPN22WD82yduqqEphp2S04g8rSUjcsUq9nKHYjUmj6jX0
	r
X-Received: by 2002:ac8:2e68:: with SMTP id s37mr16352699qta.382.1552071548946;
        Fri, 08 Mar 2019 10:59:08 -0800 (PST)
X-Received: by 2002:ac8:2e68:: with SMTP id s37mr16352648qta.382.1552071548009;
        Fri, 08 Mar 2019 10:59:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552071548; cv=none;
        d=google.com; s=arc-20160816;
        b=S4EmPwb8q81anabreNhyx8fDTeCRMZefPo4pNr4M587FrLADkunlUF7UURUdeDgd/W
         pR30cn3KD7Cb43iu5xS4UpOjlcXHS9JF46i/s1OVlXwOw6hl0uxk1auPFoksPDGKONpD
         GCXmrJ7NI3L/3QKobhv9l3Tygu+YGKnpeGBClBFBGdWUNNIhVzloFVEjv4PH59owUE7f
         hMRPu0nQIL+TJ/Iu44WZHq4SHjW9Y1Q1KQEzP2lK6Aotqdl+3SxhzZMG9zohDBFlrZSG
         Ke2h/qM19IHiF84b4dm6Q2TOUZOqwdrKukrCbdCXaHVz0gD6F7Zv5tC4aroVbbeGT988
         ZXRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=13oWsy/a9o3RwpeIQWA/iT9VogWPwGVjX2GBI/RlvM8=;
        b=QFTTQNFY/kho7RBHqZF+heQTXkXAxBZ4wnIpTMuK3x4BWZqurbj/NT9aY66imU3qef
         SjlW1rXT81C3s6FYqS48F6AybtO91ma8inmXGt4LYybKS8iHGaaNTufNbpPN5XxfrY24
         qav2hmbyi+BuDm/FIrX0NWGzrRkOoZqe/JdSj0OoD6+oMp/Cz5VisbCnp3RgOthg7Akd
         oiMH8b2nberISRU/nc49RlMf8JP2sICI0kQxySteDoMu2J7Uw4DwW1YqWB2GHLBrWkkp
         Qs3KWS4vtURMw95TPxQGV/DEwKGzyUtN7iU51uQQ5/T33s1bltza3dEonb4o7sSBJ7yr
         Envg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h125sor4800223qkc.37.2019.03.08.10.59.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:59:07 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxtDg2pEPSqzUac+XPgrm2KksrQJYLXsAqYO3LAbz3jzQ61EOY9bkRsfy0GxkCyLvQM+ozUYw==
X-Received: by 2002:a37:c313:: with SMTP id a19mr14686923qkj.220.1552071547588;
        Fri, 08 Mar 2019 10:59:07 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id u10sm5549480qtu.42.2019.03.08.10.59.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Mar 2019 10:59:06 -0800 (PST)
Date: Fri, 8 Mar 2019 13:59:04 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: David Hildenbrand <david@redhat.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest
 free pages
Message-ID: <20190308135700-mutt-send-email-mst@kernel.org>
References: <20190306155048.12868-1-nitesh@redhat.com>
 <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com>
 <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com>
 <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
 <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 08, 2019 at 10:06:14AM -0800, Alexander Duyck wrote:
> On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
> >
> > On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> > > The only other thing I still want to try and see if I can do is to add
> > > a jiffies value to the page private data in the case of the buddy
> > > pages.
> >
> > Actually there's one extra thing I think we should do, and that is make
> > sure we do not leave less than X% off the free memory at a time.
> > This way chances of triggering an OOM are lower.
> 
> If nothing else we could probably look at doing a watermark of some
> sort so we have to have X amount of memory free but not hinted before
> we will start providing the hints. It would just be a matter of
> tracking how much memory we have hinted on versus the amount of memory
> that has been pulled from that pool. It is another reason why we
> probably want a bit in the buddy pages somewhere to indicate if a page
> has been hinted or not as we can then use that to determine if we have
> to account for it in the statistics.
> 
> > > With that we could track the age of the page so it becomes
> > > easier to only target pages that are truly going cold rather than
> > > trying to grab pages that were added to the freelist recently.
> >
> > I like that but I have a vague memory of discussing this with Rik van
> > Riel and him saying it's actually better to take away recently used
> > ones. Can't see why would that be but maybe I remember wrong. Rik - am I
> > just confused?
> 
> It is probably to cut down on the need for disk writes in the case of
> swap. If that is the case it ends up being a trade off.
> 
> The sooner we hint the less likely it is that we will need to write a
> given page to disk. However the sooner we hint, the more likely it is
> we will need to trigger a page fault and pull back in a zero page to
> populate the last page we were working on. The sweet spot will be that
> period of time that is somewhere in between so we don't trigger
> unnecessary page faults and we don't need to perform additional swap
> reads/writes.

Right but the question is - is it better to hint on
least recently used, or most recently used pages?
It looks like LRU should be better, but I vaguely rememeber there
were arguments for why most recently used might be better.
Can't figure out why, maybe I am remembering wrong.

-- 
MST


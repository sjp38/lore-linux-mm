Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E83C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:06:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25E1720851
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 18:06:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nkbEsXyM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25E1720851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB9748E0004; Fri,  8 Mar 2019 13:06:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A696A8E0002; Fri,  8 Mar 2019 13:06:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 930CF8E0004; Fri,  8 Mar 2019 13:06:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6823B8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 13:06:27 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v12so12619968itv.9
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 10:06:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=D5rKTyfVZijrMz/zqJoeUoWvK7hLmtFUj70DH++ifvI=;
        b=XAeGH/9mnaw4eKgKdx11wMu4LatbeaZ1GyY2xkxENtj+h1m6CHt9pzG/WQP/W/EX8V
         ICtgegkivP4GTpeN2WLRH+/o347wFNo4XWZRYIv+Ot7lmC8YCwWwIaBr3aeRYp7SGgh9
         Le/ObGOUpBJbwAorWviM3BID1ablbVGaR6mhrR0AfqrHHQyLmXd9qnj7uqIkyQExFyOC
         LjZSLa86liPbA5zx6UgS90BErl/02qs5wLeZ/kLirWXlA4Y12ItrZ2YryMGbd1ETGNQl
         XhCH6Hp6YCl17bXGM+Ikaqa7j49ICQnDMWfTF/sHIYpSW3ooL6SkPmYvxo1PtN7Ob2uH
         bdAw==
X-Gm-Message-State: APjAAAWYM+XZx6KHkvonrhIamDWGV86lIiYFt6ms6cd+WzqICKMvFulo
	KcTY44S26hINnwKgetCYbEnlszQtfRnFFw4D0BbXFwocoo5FvIzDc/Y82dugD/DKSEwVHxqMvx4
	6C3JArWg7bEZY/FeVDLOT6+ZahJI1Sd08QidGBAmHMLZQJchIoZOShJpVEtkJEwdFX2ftJboewe
	5V+eKLBzSnJDy0oVFxUxc0dB3VqflTHYh8lOQWTiNy3gNlqjNAL7Ih/jp9Hvt3LZ9n+ihSirsb+
	Tsilp/5YChNGFsGG/kX0KQoWky9/g5xZ5Czf2xL7o+TkOTyixkiaTv3+2qZx4uvZA1MN/pCiM/q
	f/unJFUM8S7MGUSLOi6NGboiZbMC2F5I+cEkmIASRA43K++rF3Xaxz/f1dM9DDVNdH511xPh3Us
	4
X-Received: by 2002:a24:e506:: with SMTP id g6mr8808031iti.127.1552068387144;
        Fri, 08 Mar 2019 10:06:27 -0800 (PST)
X-Received: by 2002:a24:e506:: with SMTP id g6mr8807972iti.127.1552068386095;
        Fri, 08 Mar 2019 10:06:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552068386; cv=none;
        d=google.com; s=arc-20160816;
        b=hgmZRewn4CHT9bcsNHIR8XSLEUTDc9WNSU/9kRVmBWwQmcW2808c7+SkwOw/Pvujxd
         t+b/YJOdbgMexzDVjk1apivLDrRq9YDyT5PUQf7FyglvWGZ8d7C66jVlz0UbK0dKJCiF
         ZmZyuHcVIFQX1QpBgkO8aEOCMDbrjW17sC1br+hjX80dsteEzWea3BY6bNVK0ss/rtw1
         7A7WFwepbmBIq5oM1B0sZeEkkCwzlaBbm/rUk4m9XY7StIFFZldRpLv/Z3BEWDMC/LJb
         mw9o4vaqZIEpDJyUGwxtVcROx7R8dV6X+jATtLE89qgN9hlYO/aYWthm/+Xcrm4CHz0d
         8LIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=D5rKTyfVZijrMz/zqJoeUoWvK7hLmtFUj70DH++ifvI=;
        b=PNYy/5GzABkMPm42Y4nBjj1tJPDhYvX0wAJ2fUt2rvyRXawrxOmQl1HaNGj7MnkKbX
         p4xzd4XBQ+BrQ/L5R8Cv7UnVrfkk2OOWn8F2lZpNK5c7MXy1NsLGjdjOYIYvLW9sBBsg
         g9E9BPm89EOWjr1EVZtC/Z5X/lTVXjIIgIz9Mp9YDSFIB2skldAybbpZMLPJj0a5KTGl
         iw3TcwiumzvWu51K+pA94bmFjkdgDs5Kw5uz0OgBSOXHTnhdJh1bJAxcqvEqMWr4023j
         BrhyZlM78RnQt6RR82n3qxPAuCUl7n7tUrQnHhXfjpks2OGSljKjop4yH95y+LXOulfg
         ZFQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nkbEsXyM;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n129sor19317791jaa.12.2019.03.08.10.06.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Mar 2019 10:06:26 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=nkbEsXyM;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=D5rKTyfVZijrMz/zqJoeUoWvK7hLmtFUj70DH++ifvI=;
        b=nkbEsXyMXcEtPbGSAf1kaE6FvSfYAjTcy/5fMk4ANcma+AlXUAnDi9hlng0LmL8mke
         Mf8a+jldG7g3805jNHaVYw3gLTVsQbhrCV19H4sucJiqbD7WwJT/MXjEWbz8YbVnTrdO
         OLbbVRTxDMd/CV1qqTEpRcDhbPbq17hO2TCk4lT53cems5JLRbNodgVs/QwxpGm28fMm
         5V+EGHqfCJJFk5PWu5r7ZQ56DykRUDlqYm+gN0pFFYlO/rPQ3NfuHGu86cnIIBnZ9Uza
         xkRu7gZyjTU8w54CFljY+1KMQUBnPYO80csf/oWXcyvanXfWzjUpGFpwuazreVN64ogb
         vCIw==
X-Google-Smtp-Source: APXvYqxe8SAllqyBBiYJBgaC2gPebe+RMsZWPiQrsuncalBXI8HdlDKnm1Ro75y9UtqsMNImF5874Z6e6mBrSivrTG0=
X-Received: by 2002:a02:2309:: with SMTP id u9mr195309jau.114.1552068385617;
 Fri, 08 Mar 2019 10:06:25 -0800 (PST)
MIME-Version: 1.0
References: <20190306155048.12868-1-nitesh@redhat.com> <20190306155048.12868-3-nitesh@redhat.com>
 <CAKgT0UdDohCXZY3q9qhQsHw-2vKp_CAgvf2dd2e6U6KLsAkVng@mail.gmail.com>
 <2d9ae889-a9b9-7969-4455-ff36944f388b@redhat.com> <22e4b1cd-38a5-6642-8cbe-d68e4fcbb0b7@redhat.com>
 <CAKgT0UcAqGX26pcQLzFUevHsLu-CtiyOYe15uG3bkhGZ5BJKAg@mail.gmail.com>
 <78b604be-2129-a716-a7a6-f5b382c9fb9c@redhat.com> <CAKgT0Uc_z9Vi+JhQcJYX+J9c4J56RRSkzzegbb2=9xO-NY3dgw@mail.gmail.com>
 <20190307212845-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190307212845-mutt-send-email-mst@kernel.org>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Fri, 8 Mar 2019 10:06:14 -0800
Message-ID: <CAKgT0Ucu3EMsYBfdKtEiprrn-VBZy3Y+0HdEp5b4PO2SQgGsRw@mail.gmail.com>
Subject: Re: [RFC][Patch v9 2/6] KVM: Enables the kernel to isolate guest free pages
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 7, 2019 at 6:32 PM Michael S. Tsirkin <mst@redhat.com> wrote:
>
> On Thu, Mar 07, 2019 at 02:35:53PM -0800, Alexander Duyck wrote:
> > The only other thing I still want to try and see if I can do is to add
> > a jiffies value to the page private data in the case of the buddy
> > pages.
>
> Actually there's one extra thing I think we should do, and that is make
> sure we do not leave less than X% off the free memory at a time.
> This way chances of triggering an OOM are lower.

If nothing else we could probably look at doing a watermark of some
sort so we have to have X amount of memory free but not hinted before
we will start providing the hints. It would just be a matter of
tracking how much memory we have hinted on versus the amount of memory
that has been pulled from that pool. It is another reason why we
probably want a bit in the buddy pages somewhere to indicate if a page
has been hinted or not as we can then use that to determine if we have
to account for it in the statistics.

> > With that we could track the age of the page so it becomes
> > easier to only target pages that are truly going cold rather than
> > trying to grab pages that were added to the freelist recently.
>
> I like that but I have a vague memory of discussing this with Rik van
> Riel and him saying it's actually better to take away recently used
> ones. Can't see why would that be but maybe I remember wrong. Rik - am I
> just confused?

It is probably to cut down on the need for disk writes in the case of
swap. If that is the case it ends up being a trade off.

The sooner we hint the less likely it is that we will need to write a
given page to disk. However the sooner we hint, the more likely it is
we will need to trigger a page fault and pull back in a zero page to
populate the last page we were working on. The sweet spot will be that
period of time that is somewhere in between so we don't trigger
unnecessary page faults and we don't need to perform additional swap
reads/writes.


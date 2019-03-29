Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79D2FC10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:51:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0494F218D3
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 16:51:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0494F218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 620DC6B000D; Fri, 29 Mar 2019 12:51:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CE7E6B000E; Fri, 29 Mar 2019 12:51:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BDC86B0010; Fri, 29 Mar 2019 12:51:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 274D86B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 12:51:32 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d131so2265560qkc.18
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:51:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=JnQtOm1yPrnbkzP6/W9hj/ZhgDKVeNsjW2OawjBvYTY=;
        b=fa+freWA4gXK2DoNNj8xeoSlQFTXJN5j0zwdyOl5W+DLPAhmrTcvXv9JmwF/c6LqMa
         02OYVI1veCTrI0LfV3qgOCLBZMF5s087x06IEdPAGwIWXtTHe5qdwW2sw/iwfVMfN7xE
         qSxqrvyIz5QnqoeadOa8+8Badg0kguQp02ZG0wb/ze1cxG39bl8pPcmnL0uakkARc2Fg
         b7tbglr2aReMJYERKoZYbJAoHOjWbLOrPHMgZzz9dICH8n3mgIsLv7bmTJd3V911DpSR
         11WQrkWRenK4J6BdSCiHcIpDnHfE10zUO0rIxtAq32Zj4m+VS2g9nchtmK3JjOVyme3H
         z2Cw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLYMVaLeOS10BYq5EWSGqBuvFdDZWR7o6lFMbKvq650lJ2NCi3
	QyfeXq/4pVoQg4lR6xeKV9Y0gTWFDfSd3PsKvUvW+7bEk5cRrcJw7uQbGTaboW9t2wUb8omjGpk
	mrKQ97ptQRThLRxD/otuDvgSs/Bd31LyyHurgXYktkfyh5zY++xgBx9UelKtBfXPdUw==
X-Received: by 2002:a0c:d217:: with SMTP id m23mr39595274qvh.154.1553878291857;
        Fri, 29 Mar 2019 09:51:31 -0700 (PDT)
X-Received: by 2002:a0c:d217:: with SMTP id m23mr39595230qvh.154.1553878291089;
        Fri, 29 Mar 2019 09:51:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553878291; cv=none;
        d=google.com; s=arc-20160816;
        b=kzA6uA0AUWIvJbD4kM72nkODWc7BFY0a8J8Xrx6GgzQbZtEtPta9VtFREsWOyyo1ZL
         +5QdLLFGOcpfJbElcuSnO0T2OKNjBEHz6iKTp0t8PfoCJUG88WJ125p5HrxJ16sdnJ60
         j7EWQDyT4Fsj4jZW9HV1IQ3wnNKRWUSQljzVp0imdJ3XzLCiemeJDoUVN4aLRmhB7esW
         hxrSqJfJoFJK4ctbFRg6rIjCdhb0115ws9Eo5FxJtAdiPRaExzyC7ByC1OLIEeOyH/Hs
         ujEdJwk9j5n3XpZND6JjHJwC0qc0ORkKz6vfumGOb3LymTdphVqS9f+PC13ZT+oDTJHW
         8coA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=JnQtOm1yPrnbkzP6/W9hj/ZhgDKVeNsjW2OawjBvYTY=;
        b=hrmLcGaYM1cOraBmEQ95W4fDlpaKsvCyNaFD2ME8rK3+XL2DkOyAU1IftCrdc4Bl3Q
         9kcextHCGMgqXxfXPHWIGZV++XIjgJHdKqtA+0DUruc01Iplth5DLGaPwiqEA8ELQWBo
         Qz6nydgvM01UtdZcXAERUllvIO6Tb+4wmNn9dZG/EQZurDkOmabXm2WauOFhfEmwlfSM
         D2LNUEM1Vu3MhiIolIhSVOGO50Jzk0n//Icg6ZC5bG0I9Y3i6hF5oAotl4dzAman+F6n
         8nWVp/fVO6yTTdEghWj3LGvkL79Un+7NjTKHeu7wPcwusABIa4sKTCf9EOzN38/qZGze
         e7Qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6sor2757016qve.15.2019.03.29.09.51.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 09:51:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxBgfBkI11ElcG4ShAYKMBjANr6IPgccDr6/JrHGDJDvwRxxD++gvYrD29fhyrttrIle3nwrw==
X-Received: by 2002:a0c:a424:: with SMTP id w33mr41335410qvw.5.1553878290672;
        Fri, 29 Mar 2019 09:51:30 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id x201sm1403846qkb.92.2019.03.29.09.51.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 09:51:29 -0700 (PDT)
Date: Fri, 29 Mar 2019 12:51:26 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190329125034-mutt-send-email-mst@kernel.org>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 04:45:58PM +0100, David Hildenbrand wrote:
> On 29.03.19 16:37, David Hildenbrand wrote:
> > On 29.03.19 16:08, Michael S. Tsirkin wrote:
> >> On Fri, Mar 29, 2019 at 03:24:24PM +0100, David Hildenbrand wrote:
> >>>
> >>> We had a very simple idea in mind: As long as a hinting request is
> >>> pending, don't actually trigger any OOM activity, but wait for it to be
> >>> processed. Can be done using simple atomic variable.
> >>>
> >>> This is a scenario that will only pop up when already pretty low on
> >>> memory. And the main difference to ballooning is that we *know* we will
> >>> get more memory soon.
> >>
> >> No we don't.  If we keep polling we are quite possibly keeping the CPU
> >> busy so delaying the hint request processing.  Again the issue it's a
> > 
> > You can always yield. But that's a different topic.
> > 
> >> tradeoff. One performance for the other. Very hard to know which path do
> >> you hit in advance, and in the real world no one has the time to profile
> >> and tune things. By comparison trading memory for performance is well
> >> understood.
> >>
> >>
> >>> "appended to guest memory", "global list of memory", malicious guests
> >>> always using that memory like what about NUMA?
> >>
> >> This can be up to the guest. A good approach would be to take
> >> a chunk out of each node and add to the hints buffer.
> > 
> > This might lead to you not using the buffer efficiently. But also,
> > different topic.
> > 
> >>
> >>> What about different page
> >>> granularity?
> >>
> >> Seems like an orthogonal issue to me.
> > 
> > It is similar, yes. But if you support multiple granularities (e.g.
> > MAX_ORDER - 1, MAX_ORDER - 2 ...) you might have to implement some sort
> > of buddy for the buffer. This is different than just a list for each node.

Right but we don't plan to do it yet.

> Oh, and before I forget, different zones might of course also be a problem.

I would just split the hint buffer evenly between zones.

> 
> -- 
> 
> Thanks,
> 
> David / dhildenb


Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D57C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:45:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8397B20840
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 14:45:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8397B20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7E5C6B0005; Mon,  1 Apr 2019 10:45:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2D976B0008; Mon,  1 Apr 2019 10:45:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C44C06B000A; Mon,  1 Apr 2019 10:45:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A58306B0005
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 10:45:31 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id a15so8613653qkl.23
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 07:45:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=gMWFXOF84tirN8vJJaH4r/H0McFie5EFwhOH5jwK39Q=;
        b=bTlgxN9s095UUrtHFyWOm+BKL5kH+DxPfAFAdoVQP0j1LUBggPGKP4Mk6gP4I4LsZi
         HhbaLJFxeM1BscHwyRcsLIBuOKvgAP7f0rwLQ7B7kp9ZLvA5nCkxBo5jCEKCSecTNAOx
         Y4DpYygp9RoxboIPtuKVnjiYG4wAlWj6MOXsPZQNCnFOo6SuM2IIxFxgBjLEUOdvOp1S
         6GPh7VMq87/IaP2fE1SJZBEeh3wR9vtCiFwLzhxU4fR/NqrXKwNO7Cmc8Q8exFTIsTfD
         m2UprBUKmYxUDf+QW9G+czq/pUsHAA7rEt6+F851EndsRCYmH51fwMekGtDD6GcS31mg
         73pA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWQR1dppoMBTK4Hc6tQXq2hY+IUYU9m9tpONAmDNDRtXMQB/F6W
	7+gGFViX5qfAeHF47mkFK3F6R9WDlrfidOTqCkv2cdsGln/ys7PfxNUqd7QTb4+mB8oWzpHzWNJ
	hSEDFXWpIXNHZlLUECGBeP/7VH+h2yKkKU5a+9ZrbzIIbeu3Ksk+dPEHm3Raz/osWag==
X-Received: by 2002:a37:ef19:: with SMTP id j25mr50229112qkk.176.1554129931405;
        Mon, 01 Apr 2019 07:45:31 -0700 (PDT)
X-Received: by 2002:a37:ef19:: with SMTP id j25mr50229058qkk.176.1554129930787;
        Mon, 01 Apr 2019 07:45:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554129930; cv=none;
        d=google.com; s=arc-20160816;
        b=0DjHw/nsjx03/zHhqn5lX/M8lEseVQkP//TmvRiVCavl7/OzwdQKwvUhNefEtbQlDO
         rdCEEWiTOCZ8Pt1fsCRJbGlp0+8IEKlFjm+01EV8vNo04RYVhXXHy8LOijo3Z2kANWm9
         GhvfwNqTP0ADi8K8boveLudgDhSirjTDs64lS2FULD8AfYeSzSF1kB1oCktOVvPZ6A74
         eMelT1UO8RkJTBlx2QjeEIkk6ksciyYWAizsncw4ZyFGHy2KwpCNn4pwCGEcJ206dyAw
         BBxDXTo6JAtJ0+1Dg832swhFE154KKs8CATTRMXhi2msICzvp824kJ157QwLKWJrkcJN
         pZ5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=gMWFXOF84tirN8vJJaH4r/H0McFie5EFwhOH5jwK39Q=;
        b=USx/Okt6db+pLScii+JJIjcDxPAOmhnIAxAPTkn5C1WUu5CA53vt3fRQ4VgIq3u+2N
         dLhiA9it+zd0uzCoUQKXaoqkrxxuFTv8o+VDhORgWOIBN/r1bty3tjJlBMzdqdChxD0u
         GCU49DEIe2YuRE3qMUv1dhEdssusvN2Ehg0oeCEG0SmA+FhswuDj0vk+Tj2+Na2oCH+R
         35zExXC6nGOIDYIbIKU4qAMcp7UeoWA/sFIpQv/3Iwsvo4slOZ5Il+SI3IAs+HlwZWDe
         nKb4QhUG2m9K1VmQYb3XqGa5zvuvfJ6uZGG8P8tB3KDlbpYNXvyQFe9trVtew9fKZ7Q/
         yu5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d12sor10507311qvh.69.2019.04.01.07.45.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Apr 2019 07:45:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzJBJY8DrD6iTliprqMc4U5/LFnbB2DPVMUWe0YjnKWLftbU9KgcgwpqYMeNv25dt8ev3bOFA==
X-Received: by 2002:a0c:ae04:: with SMTP id y4mr46602243qvc.49.1554129930417;
        Mon, 01 Apr 2019 07:45:30 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id b46sm5053834qtk.77.2019.04.01.07.45.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 01 Apr 2019 07:45:29 -0700 (PDT)
Date: Mon, 1 Apr 2019 10:45:21 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	pbonzini@redhat.com, lcapitulino@redhat.com, pagupta@redhat.com,
	wei.w.wang@intel.com, yang.zhang.wz@gmail.com, riel@surriel.com,
	dodgen@google.com, konrad.wilk@oracle.com, dhildenb@redhat.com,
	aarcange@redhat.com, alexander.duyck@gmail.com
Subject: Re: On guest free page hinting and OOM
Message-ID: <20190401104328-mutt-send-email-mst@kernel.org>
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
 <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
 <20190401073007-mutt-send-email-mst@kernel.org>
 <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29e11829-c9ac-a21b-b2f1-ed833e4ca449@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 01, 2019 at 04:09:32PM +0200, David Hildenbrand wrote:
> > 
> > When you say yield, I would guess that would involve config space access
> > to the balloon to flush out outstanding hints?
> 
> I rather meant yield your CPU to the hypervisor, so it can process
> hinting requests faster (like waiting for a spinlock). This is the
> simple case. More involved approaches might somehow indicate to the
> hypervisor to not process queued requests but simply return them to the
> guest so the guest can add the isolated pages to the buddy. If this is
> "config space access to the balloon to flush out outstanding hints" then
> yes, something like that might be a good idea if it doesn't harm
> performance.

The problem would be in testing this unfortunately. Same as any
OOM hack, it is difficult to test well.

> -- 
> 
> Thanks,
> 
> David / dhildenb


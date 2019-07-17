Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F6B5C76186
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D59092173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 11:20:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D59092173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F3CF6B0003; Wed, 17 Jul 2019 07:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A5636B0005; Wed, 17 Jul 2019 07:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46BBC8E0001; Wed, 17 Jul 2019 07:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 269A46B0003
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:20:57 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c1so19776741qkl.7
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 04:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition;
        bh=VE3YIGYcV3g+ik7exL22WJT4Jq3zzmYu4pf0aT2qjHM=;
        b=LsTmjQG8v9S2WqWPEs8Bh/vJ8EWQg/8H9dUxsAR/kkQaWKB9nNgIYLVxd3/sFPlSKb
         yLV1uRF6uy7986acE/C/lKYu5VJSAnc4HD3Ub9J7dMmxkkd6AwK+i10sg4bz+YbuWb10
         oj82wQz+b0l0paz7LoTeiFH3A65aMOhVwj6ktSXZNXtmUl8WlbY/0jTHqIxgzSGfzH8u
         yKWI/SlgXlT4R2HjpxUn45dOrZoMVjG+gP+43+9pgeVoYspJhonJNfl3e3raCS3O7Zh0
         NeBKhZPcevt5XWoOPXWmwI/AOOoJceJJnBmtYqNr7nani2UaFsiZYxAhZ4OuJ5FJZD95
         xA6g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXeIMRD9FXccgOAxBj+1sS0/3GkflNXDfkqDDOtpY07Zsb6/EVH
	x9u6TEf/aAZ5IdtwRBWDU5ClzD00C9BhB12HwRbC6h4sPbIGWlgNmKexoEgjy8QXZhlOhdbiHFR
	s9yf4Kp1p40IB0z9GQY1UYuIdYKpvkH1rBDdOgCFlKIkr1E+KwZYNTx5W0fbZtMW51Q==
X-Received: by 2002:ac8:1c65:: with SMTP id j34mr27104153qtk.323.1563362456949;
        Wed, 17 Jul 2019 04:20:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwoOBbz/m7pDA+vcOeyELYpnkwFepzfE/6Et6cCwTN5/OFIo9aQzQm8ywihFAACaaOOXva9
X-Received: by 2002:ac8:1c65:: with SMTP id j34mr27104107qtk.323.1563362456298;
        Wed, 17 Jul 2019 04:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563362456; cv=none;
        d=google.com; s=arc-20160816;
        b=u4UvQpRSc75CvqVjqUOiiT1SCb4NBknE/9+KMEu0q4gRruBDT8W33VDfCsGgCfmr6m
         fTyeNoNvwCl+40WFsbDvCgicjsTYjho5lu6Xdl7xJq/Q0bRoE5co24qPNrvD6chKLcDg
         +osxzZXIQ5W9TD2ClD0t0EeGlFZXHRqhgBc3N8BlXVt92uflE7KCoBIjOh9TmUZV041E
         GqLJIfw4q3r3k5kKbrtbVlXNqAkvWSGpnN3+2hk1JlrkzKZdbuybpyMOdL+kImfDtNrA
         7W252BvVSkCIINd8NJN5Y/hD9E89nEg1SEe8MiOJ/ZXP5b4wbbpiKcJLtNvK/7HXLRe1
         ylQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date;
        bh=VE3YIGYcV3g+ik7exL22WJT4Jq3zzmYu4pf0aT2qjHM=;
        b=aghgm53/aZjYdSYupM2UEwPyFdzgsBYpPV9EchKK6Rfgu7I0TxPTJA0dQ2VCb+Gcbi
         FJObF/aLyvQpDqIZo0KOw3zme/MFEmfRS5J8vHZgHWWusgpZByA6bIDKBYIr1BGCYhjE
         iHda8diIH81+bFbEbDiQQt+rxs2/F18117L8fY3UmquNQZHvf8R0NzCAmQ6GsEgEzz5b
         rETuqZefnlLXfYY+Oe26YPzBhrExXyBSSHT1lb+Vc4XWETbswZq7QlWSIj9EPlAeQE2q
         IBQD4ftU7V8rXEwYuI+Voc1NkvbL6Oo+71og6gyKg/RcDYzaL53JoUG28gT0fMWNKiPl
         SEtA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d52si16338878qvh.214.2019.07.17.04.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 04:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5B1D33082133;
	Wed, 17 Jul 2019 11:20:55 +0000 (UTC)
Received: from redhat.com (ovpn-120-247.rdu2.redhat.com [10.10.120.247])
	by smtp.corp.redhat.com (Postfix) with SMTP id EB7D55C232;
	Wed, 17 Jul 2019 11:20:34 +0000 (UTC)
Date: Wed, 17 Jul 2019 07:20:33 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: wei.w.wang@intel.com, Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Dave Hansen <dave.hansen@intel.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
	Rik van Riel <riel@surriel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	lcapitulino@redhat.com, Andrea Arcangeli <aarcange@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Subject: use of shrinker in virtio balloon free page hinting
Message-ID: <20190717071332-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 17 Jul 2019 11:20:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Wei, others,

ATM virtio_balloon_shrinker_scan will only get registered
when deflate on oom feature bit is set.

Not sure whether that's intentional.  Assuming it is:

virtio_balloon_shrinker_scan will try to locate and free
pages that are processed by host.
The above seems broken in several ways:
- count ignores the free page list completely
- if free pages are being reported, pages freed
  by shrinker will just get re-allocated again

I was unable to make this part of code behave in any reasonable
way - was shrinker usage tested? What's a good way to test that?

Thanks!

-- 
MST


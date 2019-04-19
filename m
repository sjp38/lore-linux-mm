Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3EA2C282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 06:01:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BAB521736
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 06:01:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BAB521736
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46976B0003; Fri, 19 Apr 2019 02:01:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACDE76B0006; Fri, 19 Apr 2019 02:01:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BCE86B0007; Fri, 19 Apr 2019 02:01:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 780586B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 02:01:22 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z19so839026qkj.5
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 23:01:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=uh9uz+GC6+XQ9S6ZONPZ+4z7+/SOxMz7IOadYrzwT2w=;
        b=TO1uVKFdrq2QMXvS/eQgB2iNLtYaymqzgCqD9vmrtq+75PyKN1aXqEy6qM4H/pEBjX
         8dxo0xcD3NgCUYbZd4GM3FR/qAp8mN4+kXUseNVJk+oLij8rJH89mRwrBz87UaMV0dUc
         01CkSZh4Dupc2Un2lRnIkWz+5F2m2kGctEBiWo1+XqvDxw9hmvowpiFEC7v0dpJzwqJe
         oemR7A63kPMhHtn4no4fqLJ6CBPEz7KoxZFKOITIcFOy932vFGTgexAhTvXb0gbnmngS
         8HKCw3ywinSUvcZm01l+sOfsw4dsU+lG3OCKYRgkaSHz7QhbdCZFpUC8sIPAqbJGVmdJ
         WpMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUdphIuzcN0AL7GERGHP2OR7+9HlGTd0o17hd0u7iTueVZ0Q/OH
	0UB1xSoP34H0v1cHAjkyD0Ff7eP7HRxZ9HSfaflsUQaREn2ls5WtZBbj8McRsY4OKBHlXvuNIjY
	n2ThUQy16gKFgNMt/Hsq2JPGhuAZdT3Ukskgt1wo9dmuKQ2Nyg4uRvT22QaF522EPUg==
X-Received: by 2002:aed:3e33:: with SMTP id l48mr1966919qtf.278.1555653682214;
        Thu, 18 Apr 2019 23:01:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyyT+NmJDkHoTpmHd4nK9xOawVzTiFWaDYiBuK1F22KtRRt9SUksA+XWI4PkwnKO3MIDJXg
X-Received: by 2002:aed:3e33:: with SMTP id l48mr1966873qtf.278.1555653681486;
        Thu, 18 Apr 2019 23:01:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555653681; cv=none;
        d=google.com; s=arc-20160816;
        b=P2UbIFXPFI3o0AkZoKMuY4Lms2HE+DDDmrDBBHSCaVMAc1CMjF+P5TOCB5ICzxVzTV
         KtTJHy5ZuHfn3caI9vPDEq3TiShk/BquAFJh+W+fwRb/dRd+uXC02s538prfcywW729z
         nmHus2N6eR9oIsnzGtcuIPxDLM8G2OE0NAm1+kVqdhZkxUWV4nsPGypn6okTJ6yOhSmF
         fOl+Gpj+3Rq4ErKRzBJrGelT/YHL3xSDYxpEyOM3zGBJ4nlCJtYAC/+ypJrJmKIglgOZ
         YPVA728o4RkCRfs1NyzfDgMjV08BhuuPNzQ5sqNnlYJUCckaGcMNfweiDC8k/itlu5ay
         SQrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=uh9uz+GC6+XQ9S6ZONPZ+4z7+/SOxMz7IOadYrzwT2w=;
        b=ExUe0AxRNHKojkMDEeni0RVkHpngUbusr9/wF8XcPzBBuN8Vns8T9FJeKoyo7DV4qB
         kbHFGnozDq34cJfBUAwolIq2toBnaEnvK0hsFHxvJvIxHdLn7twRXQuS2KCplqYP6cb5
         GueaI/I7ivu2RO0rIdvX5iZ1WOhdg2F6b6cfzBqdPMCQvCqvR1gaG2r/+aZYaQr9jlr2
         HY0dEcZAL+fGrWtnySsE728wKK1uPYMLL77xkODYsMY5Uuvof91nWdhRDh1BcCoIA8u7
         KiBPTkXidYqQ2VEZifI2hTA7T8zWED2n9n8Aq10Ek7WEHhCHYyWsD89JKw2zKdhA9Y7/
         br/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f50si2709029qtk.357.2019.04.18.23.01.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 23:01:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D30F430BC642;
	Fri, 19 Apr 2019 06:01:19 +0000 (UTC)
Received: from xz-x1 (ovpn-12-224.pek2.redhat.com [10.72.12.224])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E1A0E60BE0;
	Fri, 19 Apr 2019 06:01:01 +0000 (UTC)
Date: Fri, 19 Apr 2019 14:00:57 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v3 04/28] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190419060057.GE13323@xz-x1>
References: <20190320020642.4000-1-peterx@redhat.com>
 <20190320020642.4000-5-peterx@redhat.com>
 <20190418201108.GJ3288@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190418201108.GJ3288@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 19 Apr 2019 06:01:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 18, 2019 at 04:11:08PM -0400, Jerome Glisse wrote:

[...]

> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> A minor comment suggestion below but it can be fix in a followup patch.

[...]

> > +/*
> > + * Returns true if the page fault allows retry and this is the first
> > + * attempt of the fault handling; false otherwise.  This is mostly
> > + * used for places where we want to try to avoid taking the mmap_sem
> > + * for too long a time when waiting for another condition to change,
> > + * in which case we can try to be polite to release the mmap_sem in
> > + * the first round to avoid potential starvation of other processes
> > + * that would also want the mmap_sem.
> > + */
> 
> You should be using kernel function documentation style above.

I'm switching to this:

/**
 * fault_flag_allow_retry_first - check ALLOW_RETRY the first time
 *
 * This is mostly used for places where we want to try to avoid taking
 * the mmap_sem for too long a time when waiting for another condition
 * to change, in which case we can try to be polite to release the
 * mmap_sem in the first round to avoid potential starvation of other
 * processes that would also want the mmap_sem.
 *
 * Return: true if the page fault allows retry and this is the first
 * attempt of the fault handling; false otherwise.
 */

I'm still keeping the r-b, assuming that's ok.

Thanks!

-- 
Peter Xu


Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48B04C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 16:04:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EAC02217F5
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 16:04:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EAC02217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 477588E0005; Mon, 18 Feb 2019 11:04:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3FFBB8E0002; Mon, 18 Feb 2019 11:04:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A1E88E0005; Mon, 18 Feb 2019 11:04:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB5338E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 11:04:21 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so15279790qkl.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 08:04:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ZBLP75mPAnic8DYjGI7knlnw73Ej8gDgUXGZpKGkrUw=;
        b=rmQOq3Jspg0szEAFyarLJakKKAVQMtL2bVdCclVAU+AOJoKpbYafPrUu8SSOuKy56/
         Ji7HEfnzqKWTBZyYwMrS8jRLGJErnvhcW/xDKyDKEI1bO4FC8Tyz+Z69xU95JeQZH9x4
         1EPaUsgbR5NV8tYT5QriIfY/jZlkOq4xT4SIiFn5QN1gG07mihcCaSRGPEldyLjJZKYO
         C6ZqNP1bly6cxsjRZWVgx21mtzbDwVnYy1nRjODVfHXiTDG7ufomLVwlDAGBNHVlvvPL
         U4a6OI1Re8ZKD2okU1MCg/wYPtxqqHnQ91ebQcgTA6RJcah6WxkI2d5qJDag7ljZ5Pdj
         cDgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaJdTfEgpc1OIA/SxhiDFaYn2tfGExXaFXhW3z1YT0HJdKFLgHh
	n1NMOCIbeBhA0Gb6UhUxjrQSX7Chzp7NqlIzp0EgZ8i+sUEvVHsQGi7g6DG0tIqu3lP0Fhk7PhT
	m763mCMY2sXUwkIKqAyRGNEB9vi19HHXXzlhINXS/QHcq3DauKZ4mbewhj06+nZzuXQ==
X-Received: by 2002:a37:634b:: with SMTP id x72mr15461319qkb.151.1550505861662;
        Mon, 18 Feb 2019 08:04:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZxsaiPV1PpUrFSeGGd3QOqIJgspv7Xjbbl9oIKidFSUxW1Hi+iWk94FDrl2FHe9BXu+jqm
X-Received: by 2002:a37:634b:: with SMTP id x72mr15461258qkb.151.1550505860755;
        Mon, 18 Feb 2019 08:04:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550505860; cv=none;
        d=google.com; s=arc-20160816;
        b=osc9Bac/ZOY2NF9xtTmQg0zv080maMhkZt1RGW0xHmupsLBetGkmQXJWh2EkXNM2Q3
         SS3xD+24BTAWDPtUWMvMz8+kqMQXQlcphq45Yf5jeFIXagOn8yVZGVkDdZVdpjhCeJUD
         JemGyUmKyFfB5mtGOLLV2qr+TjzA3SKE4ubebTiTzj7kv++aZGlrn1iGOqAMzVPQG7Oc
         KL82es8HeHvKHeZRbWOLfeuPhcrygDm8/mDRRbvbHYzeh8mCzk4udyVYUCfGUbqEnVxx
         oAzeH7dS2nhB/jFL8EBwy34/qStI9eJ7dcRQ9tzKlCUCDAqrdGzgNR3Ja5qRN+T2zazK
         DS7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ZBLP75mPAnic8DYjGI7knlnw73Ej8gDgUXGZpKGkrUw=;
        b=e0rmgyTTNQSOqXs83XScBTSY2fmlExfm8hrEy41/7o8fDDVAdq1Wi63PCNG54UDPPj
         g0B3oqAUzFGzZFOjOlIfQOXz0hI9nibhEUKRlfOSC28Zg2Kf88aI7D5i6I2JGUqwWDuB
         J4Lb4CNwLjsPzWTZpJYSPiibsb/MEFUC+sPErfCu+IpyKwp6JsWg9xSzd1N59/sJQgfG
         WWCKGjLXjqurBD/FSlur9YKaRh5XdTWbaBb1aMh3rW/HL6QIjYzUQLFrMEWfT4pk4Wq5
         Oyn3+bOQj4EXJSJhxVI8F0OBMh8pgK/YRKVgRPaUFbfDjxFTj0nrpNDIz4fgu/S+6wvU
         x9BA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 46si1630858qve.148.2019.02.18.08.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 08:04:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 18709315FC5;
	Mon, 18 Feb 2019 16:04:19 +0000 (UTC)
Received: from redhat.com (ovpn-125-191.rdu2.redhat.com [10.10.125.191])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id DBA20A68E5;
	Mon, 18 Feb 2019 16:04:16 +0000 (UTC)
Date: Mon, 18 Feb 2019 11:04:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190218160411.GA3142@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
 <20190211190931.GA3908@redhat.com>
 <20190211200200.GA30128@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190211200200.GA30128@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Mon, 18 Feb 2019 16:04:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 03:02:00PM -0500, Andrea Arcangeli wrote:
> On Mon, Feb 11, 2019 at 02:09:31PM -0500, Jerome Glisse wrote:
> > Yeah, between do you have any good workload for me to test this ? I
> > was thinking of running few same VM and having KSM work on them. Is
> > there some way to trigger KVM to fork ? As the other case is breaking
> > COW after fork.
> 
> KVM can fork on guest pci-hotplug events or network init to run host
> scripts and re-init the signals before doing the exec, but it won't
> move the needle because all guest memory registered in the MMU
> notifier is set as MADV_DONTFORK... so fork() is a noop unless qemu is
> also modified not to call MADV_DONTFORK.
> 
> Calling if (!fork()) exit(0) from a timer at regular intervals during
> qemu runtime after turning off MADV_DONTFORK in qemu would allow to
> exercise fork against the KVM MMU Notifier methods.
> 
> The optimized change_pte code in copy-on-write code is the same
> post-fork or post-KSM merge and fork() itself doesn't use change_pte
> while KSM does, so with regard to change_pte it should already provide
> a good test coverage to test with only KSM without fork(). It'll cover
> the read-write -> readonly transition with same PFN
> (write_protect_page), the read-only to read-only changing PFN
> (replace_page) as well as the readonly -> read-write transition
> changing PFN (wp_page_copy) all three optimized with change_pte. Fork
> would not leverage change_pte for the first two cases.

So i run 2 exact same VMs side by side (copy of same COW image) and
built the same kernel tree inside each (that is the only important
workload that exist ;)) but the change_pte did not have any impact:

before  mean  {real: 1358.250977, user: 16650.880859, sys: 839.199524, npages: 76855.390625}
before  stdev {real:    6.744010, user:   108.863762, sys:   6.840437, npages:  1868.071899}
after   mean  {real: 1357.833740, user: 16685.849609, sys: 839.646973, npages: 76210.601562}
after   stdev {real:    5.124797, user:    78.469360, sys:   7.009164, npages:  2468.017578}
without mean  {real: 1358.501343, user: 16674.478516, sys: 837.791992, npages: 76225.203125}
without stdev {real:    5.541104, user:    97.998367, sys:   6.715869, npages:  1682.392578}

Above is time taken by make inside each VM for all yes config. npages
is the number of page shared reported on the host at the end of the
build.

There is no change before and after the patchset to restore change
pte. I tried removing the change_pte callback alltogether to see if
that did have any effect (without above) and it did not have any
effect either.

Should we still restore change_pte() ? It does not hurt, but it does
not seems to help in anyway. Maybe you have a better benchmark i could
run ?

Cheers,
Jérôme


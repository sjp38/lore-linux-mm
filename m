Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ACEACC10F01
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:45:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75289217F9
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:45:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75289217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16B8B8E0003; Mon, 18 Feb 2019 12:45:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1416A8E0002; Mon, 18 Feb 2019 12:45:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05B518E0003; Mon, 18 Feb 2019 12:45:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id D05698E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:45:12 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id r24so17547743qtj.13
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:45:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=xium4DNsIwE0GETMtJ1vhqHzWepOsgjCEK+xDplkyWw=;
        b=hpK2EUJ8UboxcTGTsn997SjPuMsLwN5mvsAGO6sH1l5aKUaktHCuHehNAk2czNmMHc
         7DkhzXlutzwPlvOqpMSg9szOPavrV6GzHnmmevleFgveVlYUfbD0F5OGo0oy4ggPUrz+
         YNQ2PV9b4WsUxi9b12ytmaiEHsMzyBTSf6/1q+3DP6HYqNEELeSSIIRHeTwHRTqgUm1F
         eq5MHveoMPg0j/YRmE9oCC/HmP5+tqd/DsQaAK60DJLKNWeA9SNp0I7cy/Z5mvlIvg3m
         TGd6nIrPGliZZF9TK4l1y9FVD6x2zJlYJIFReqJPEov9YEZ53WVGjGnKy+BtvbQ5MnwL
         kZrg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZmWHyWCEbN+IFK708pRsIzA8sAx1+fjoNDIylR6WWkNWYsZ5ds
	kdq9WxGoh08vROyR1uoLW//x2Y5m+EzfCRNToh1o+W7xf46CXmzTJpbIJ9qgwG92yB2Zd1hBP0b
	z/6g1FvD/wIW4VDQ6tp8c+NqfF1cC3jiUiq1PVVYAXNdKwDctwfa8sZaErn3RYMHtrw==
X-Received: by 2002:a0c:9368:: with SMTP id e37mr18328158qve.61.1550511912612;
        Mon, 18 Feb 2019 09:45:12 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY+o7ecHagGyXVntZkCLznhY8C1X+zXwMTY+TFoRkHoNGVZyEV+ZOTzaSVIwoHL91CZexWx
X-Received: by 2002:a0c:9368:: with SMTP id e37mr18328135qve.61.1550511912068;
        Mon, 18 Feb 2019 09:45:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550511912; cv=none;
        d=google.com; s=arc-20160816;
        b=FBW5aT0FLRj7oUCXklf0vTXXKqd4NU9Dg4q5/BFsIH98seZPdqRJn+X3MZMTMOvIlf
         ElQP7K56sxInVaGbcaYAVtfSfF5793CFIWpA1j5NzQivBjUckV7cnL8F5CBbU/QW3sZR
         k8+pHA00GgnsPIJzhneyQ5FQ4jCFgZrw7hNfp6nFxmKtI+e/aXENUmX3meirfhESwSPO
         RAPaoHvynZTq4Jdv1QvIvLc0bhl8Ka8m0c8Ym2qyZGekmYA7W5SpR6Z+UBzGrllEr4d3
         a34DMciG4kmVgMuoxs1nybTOSX3UrLh5vbJ1dXgNv5OMyEX7sfkNhHyeYN6AreoMIYW9
         VTiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=xium4DNsIwE0GETMtJ1vhqHzWepOsgjCEK+xDplkyWw=;
        b=zfbgEfeMI4scMG8i+Vi5E8Mpl2ptJUS38PhWh9yjjBoHk8BJbI6hcCkLPt3e1XMT1u
         pYEeD4zaY72rAxrNobZ4abJR6fuXA+E/c7o9SGxvjbRc8hGh8nMxDo6QLk7T2tKl0dHp
         Jlz4XFqARrTM76kJStycoza49mHadcswvi8IadnpYmKKtLB8a1NDBPmH2+FSlGQPYOGe
         48EndxhbjiagwRtREvHcBtRwKykoaxWG5s1bGfYbSs6A/XvtKLTmmMRdE0mgSccuohm9
         JmnU6tt+yZGSfCK4DzY/LiraZrnfA+ipTsDrE0Rlx0vEZYIr/K+g7bG72T9MVlW+zCPT
         LHqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si4720904qvm.65.2019.02.18.09.45.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 09:45:12 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 27A7BC049E24;
	Mon, 18 Feb 2019 17:45:11 +0000 (UTC)
Received: from sky.random (ovpn-120-13.rdu2.redhat.com [10.10.120.13])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B4777600C8;
	Mon, 18 Feb 2019 17:45:06 +0000 (UTC)
Date: Mon, 18 Feb 2019 12:45:05 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
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
Message-ID: <20190218174505.GD30645@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
 <20190211190931.GA3908@redhat.com>
 <20190211200200.GA30128@redhat.com>
 <20190218160411.GA3142@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218160411.GA3142@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 18 Feb 2019 17:45:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 11:04:13AM -0500, Jerome Glisse wrote:
> So i run 2 exact same VMs side by side (copy of same COW image) and
> built the same kernel tree inside each (that is the only important
> workload that exist ;)) but the change_pte did not have any impact:
> 
> before  mean  {real: 1358.250977, user: 16650.880859, sys: 839.199524, npages: 76855.390625}
> before  stdev {real:    6.744010, user:   108.863762, sys:   6.840437, npages:  1868.071899}
> after   mean  {real: 1357.833740, user: 16685.849609, sys: 839.646973, npages: 76210.601562}
> after   stdev {real:    5.124797, user:    78.469360, sys:   7.009164, npages:  2468.017578}
> without mean  {real: 1358.501343, user: 16674.478516, sys: 837.791992, npages: 76225.203125}
> without stdev {real:    5.541104, user:    97.998367, sys:   6.715869, npages:  1682.392578}
> 
> Above is time taken by make inside each VM for all yes config. npages
> is the number of page shared reported on the host at the end of the
> build.

Did you set /sys/kernel/mm/ksm/sleep_millisecs to 0?

It would also help to remove the checksum check from mm/ksm.c:

-	if (rmap_item->oldchecksum != checksum) {
-		rmap_item->oldchecksum = checksum;
-		return;
-	}

One way or another, /sys/kernel/mm/ksm/pages_shared and/or
pages_sharing need to change significantly to be sure we're exercising
the COW/merging code that uses change_pte. KSM is smart enough to
merge only not frequently changing pages, and with the default KSM
code this probably works too well for a kernel build.

> Should we still restore change_pte() ? It does not hurt, but it does
> not seems to help in anyway. Maybe you have a better benchmark i could
> run ?

We could also try a microbenchmark based on
ltp/testcases/kernel/mem/ksm/ksm02.c that already should trigger a
merge flood and a COW flood during its internal processing.

Thanks,
Andrea


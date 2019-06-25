Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A0C6C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 17:10:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B0293208CA
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 17:10:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jTTbZRDS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B0293208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 397D36B0005; Tue, 25 Jun 2019 13:10:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 349718E0003; Tue, 25 Jun 2019 13:10:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 211518E0002; Tue, 25 Jun 2019 13:10:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 014B46B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 13:10:25 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id f22so27029607ioh.22
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:10:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+lL1R63kFmBABEWWpkPRtiAmvBaOFO/up0GD+Pi7PgM=;
        b=fgB4qGa/0hkCyEPQzJt0N5fhpbi/8LAMwjdZkUIAdYxoLEkq3qF8lYPNSBVytRMMBo
         E95FOggepCuSxSUFDp/lYJTUPJnwqRfQMf7aScnTLBSX/b/orJMckYA/1+lcVY83Xl9v
         4x8mwS+5cvnEfV9svD8A4MtKUdZd7KRqkRUUlH8pEDUtOwmLm1T5iOruVqT4mSM3DGN7
         ggt+RHLe51Zdnv39WF41mI1uALrUE3O5KsRR8Ng/MRVWZ691Jm7zd5QDs/2TrW7La7oi
         eiy7Jow4p2Vpi594lHt+8q6XovI1X1gFsi2wqGU1EItVJ8Kbvnfq+dv7HljG/muN1hwT
         eZuQ==
X-Gm-Message-State: APjAAAVJqtY6MQmghf840dAF01/JmbEUdlOVf5d5g4pbbTtKYNvcwP1O
	6MVRSd5f2lqhHPP5yHQ47StWWQxaVD8Jbz1nXv0JtZRxhM6e15wmP4bqlq9iL3HMzTEQ6tfaUwz
	3BA63UMLe2vhweSLlk0FTYxmaVqYdLwDAvicvs956ir2KdiiL+9zTOMUGPU0avxYVHg==
X-Received: by 2002:a02:a493:: with SMTP id d19mr41852861jam.22.1561482624770;
        Tue, 25 Jun 2019 10:10:24 -0700 (PDT)
X-Received: by 2002:a02:a493:: with SMTP id d19mr41852751jam.22.1561482623514;
        Tue, 25 Jun 2019 10:10:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561482623; cv=none;
        d=google.com; s=arc-20160816;
        b=UNF51hDQvOD9pZPr+SCU2XZHOt9seYQzkp5WBTeV6jzkrZiganlf+uveB1etHWE4hB
         UgX2uaaPDlko7uKZwlNinxgYOSfhkPA53ISHJU6mTjLXo5UwoqybysMJi4HKiSns7zii
         j2e/eZpG6OM6VD9gCgeARh4MZSyiQj5cLk429VGnd6Tb3JI0oJ8saSkqsULMFuU1YV1X
         A2kO3JMBn3UfIaDG/hKJ2Y2RX0eRXWa31kp3ul0REEGqt799EXiSe9YjEopwR+caYG5c
         vtI2FrUO5Uoa1TjSHuaSTi3ByptK8p5oYdfWEhzeP88kmXe9z+/1hjrE9KMfNWJ+7hQ9
         HQ5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+lL1R63kFmBABEWWpkPRtiAmvBaOFO/up0GD+Pi7PgM=;
        b=b52tku3bxfh6uzLebXTLqVt9br2EbnAU0YYVB1BbMLCQM0lvgGSM8M6cYVPqLMQyZC
         rLzYIzxnOlWks+u5Fs2XISo7DEbQEm30YPtrSyDUb1nHCFfClQ2B76y0xYxFDy6Iz6UC
         r/25FOhsQd0asBfQNfmhFx1y2hEd+xLsoBFHsVO0hD7smA1aMnRLFNLz07X+2+TANlnw
         XXtje9n0K+X6WBVqdYBMTfgF+q5LDJopjeOuSFirzbYlMGOWa30RwPj7OPtw6kPdD0ge
         EqZMmXjr+4wdDYItn4/3LxkTZ4NxWL/M5HmNx6bvIh4C88pNuJr5w7uKlvrIWtaWE3mt
         XVrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jTTbZRDS;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h26sor10366550ioh.98.2019.06.25.10.10.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 10:10:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jTTbZRDS;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+lL1R63kFmBABEWWpkPRtiAmvBaOFO/up0GD+Pi7PgM=;
        b=jTTbZRDS7h6Yjo3mPlzny0qqSwBS+vsY+EshUKSkbx96U2e72S6SaA2ZWprTdVzZoA
         EIjfHkjUU9NpZM9I3XsxIYY1p/VuNuI1qlYdLJka0s4j0jzuTvFJutQFTXS5hytCaioK
         FzgVOUzhPDY/TdgtkG/jXYqTncMf1jbfBUPYnWXTjBwh9y4esusCm6TlN/mQcyWBZE/o
         clrr2MmLj8IYyGxRx8iFqOOgETGmB+8Rj+xTajfCl1w7WwM6DvSuth90155wITWVBnaQ
         9pjeNOGbtbDFSvREpCOgUMqAUjRl+ZeQ06zCQeOBTLKQrAoCM+3Xnh08iwat+/9ASwPI
         ioVg==
X-Google-Smtp-Source: APXvYqxUAKWojy0gXmh8owAdKj5VA+deuqMh1EsSSiIpaWx6+m+b23d6ITYCyI/G3TiRvPaIjo+aszho3Z9JUDEO+Lc=
X-Received: by 2002:a6b:901:: with SMTP id t1mr23113429ioi.42.1561482622989;
 Tue, 25 Jun 2019 10:10:22 -0700 (PDT)
MIME-Version: 1.0
References: <20190603170306.49099-1-nitesh@redhat.com> <20190603140304-mutt-send-email-mst@kernel.org>
 <afac6f92-74f5-4580-0303-12b7374e5011@redhat.com>
In-Reply-To: <afac6f92-74f5-4580-0303-12b7374e5011@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 25 Jun 2019 10:10:12 -0700
Message-ID: <CAKgT0UdK2v+xTwzjLfc69Baz0iDp7GnGRdUacQPue5XHFfQxHg@mail.gmail.com>
Subject: Re: [RFC][Patch v10 0/2] mm: Support for page hinting
To: Nitesh Narayan Lal <nitesh@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, lcapitulino@redhat.com, pagupta@redhat.com, 
	wei.w.wang@intel.com, Yang Zhang <yang.zhang.wz@gmail.com>, 
	Rik van Riel <riel@surriel.com>, David Hildenbrand <david@redhat.com>, dodgen@google.com, 
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com, 
	Andrea Arcangeli <aarcange@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 7:49 AM Nitesh Narayan Lal <nitesh@redhat.com> wrote:
>
>
> On 6/3/19 2:04 PM, Michael S. Tsirkin wrote:
> > On Mon, Jun 03, 2019 at 01:03:04PM -0400, Nitesh Narayan Lal wrote:
> >> This patch series proposes an efficient mechanism for communicating free memory
> >> from a guest to its hypervisor. It especially enables guests with no page cache
> >> (e.g., nvdimm, virtio-pmem) or with small page caches (e.g., ram > disk) to
> >> rapidly hand back free memory to the hypervisor.
> >> This approach has a minimal impact on the existing core-mm infrastructure.
> > Could you help us compare with Alex's series?
> > What are the main differences?
> Results on comparing the benefits/performance of Alexander's v1
> (bubble-hinting)[1], Page-Hinting (includes some of the upstream
> suggested changes on v10) over an unmodified Kernel.
>
> Test1 - Number of guests that can be launched without swap usage.
> Guest size: 5GB
> Cores: 4
> Total NUMA Node Memory ~ 15 GB (All guests are running on a single node)
> Process: Guest is launched sequentially after running an allocation
> program with 4GB request.
>
> Results:
> unmodified kernel: 2 guests without swap usage and 3rd guest with a swap
> usage of 2.3GB.
> bubble-hinting v1: 4 guests without swap usage and 5th guest with a swap
> usage of 1MB.
> Page-hinting: 5 guests without swap usage and 6th guest with a swap
> usage of 8MB.
>
>
> Test2 - Memhog execution time
> Guest size: 6GB
> Cores: 4
> Total NUMA Node Memory ~ 15 GB (All guests are running on a single node)
> Process: 3 guests are launched and "time memhog 6G" is launched in each
> of them sequentially.
>
> Results:
> unmodified kernel: Guest1-40s, Guest2-1m5s, Guest3-6m38s (swap usage at
> the end-3.6G)
> bubble-hinting v1: Guest1-32s, Guest2-58s, Guest3-35s (swap usage at the
> end-0)
> Page-hinting: Guest1-42s, Guest2-47s, Guest3-32s (swap usage at the end-0)
>
>
> Test3 - Will-it-scale's page_fault1
> Guest size: 6GB
> Cores: 24
> Total NUMA Node Memory ~ 15 GB (All guests are running on a single node)
>
> unmodified kernel:
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,459168,95.83,459315,95.83,459315
> 2,956272,91.68,884643,91.72,918630
> 3,1407811,87.53,1267948,87.69,1377945
> 4,1755744,83.39,1562471,83.73,1837260
> 5,2056741,79.24,1812309,80.00,2296575
> 6,2393759,75.09,2025719,77.02,2755890
> 7,2754403,70.95,2238180,73.72,3215205
> 8,2947493,66.81,2369686,70.37,3674520
> 9,3063579,62.68,2321148,68.84,4133835
> 10,3229023,58.54,2377596,65.84,4593150
> 11,3337665,54.40,2429818,64.01,5052465
> 12,3255140,50.28,2395070,61.63,5511780
> 13,3260721,46.11,2402644,59.77,5971095
> 14,3210590,42.02,2390806,57.46,6430410
> 15,3164811,37.88,2265352,51.39,6889725
> 16,3144764,33.77,2335028,54.07,7349040
> 17,3128839,29.63,2328662,49.52,7808355
> 18,3133344,25.50,2301181,48.01,8267670
> 19,3135979,21.38,2343003,43.66,8726985
> 20,3136448,17.27,2306109,40.81,9186300
> 21,3130324,13.16,2403688,35.84,9645615
> 22,3109883,9.04,2290808,36.24,10104930
> 23,3136805,4.94,2263818,35.43,10564245
> 24,3118949,0.78,2252891,31.03,11023560
>
> bubble-hinting v1:
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,292183,95.83,292428,95.83,292428
> 2,540606,91.67,501887,91.91,584856
> 3,821748,87.53,735244,88.31,877284
> 4,1033782,83.38,839925,85.59,1169712
> 5,1261352,79.25,896464,83.86,1462140
> 6,1459544,75.12,1050094,80.93,1754568
> 7,1686537,70.97,1112202,79.23,2046996
> 8,1866892,66.83,1083571,78.48,2339424
> 9,2056887,62.72,1101660,77.94,2631852
> 10,2252955,58.57,1097439,77.36,2924280
> 11,2413907,54.40,1088583,76.72,3216708
> 12,2596504,50.35,1117474,76.01,3509136
> 13,2715338,46.21,1087666,75.32,3801564
> 14,2861697,42.08,1084692,74.35,4093992
> 15,2964620,38.02,1087910,73.40,4386420
> 16,3065575,33.84,1099406,71.07,4678848
> 17,3107674,29.76,1056948,71.36,4971276
> 18,3144963,25.71,1094883,70.14,5263704
> 19,3173468,21.61,1073049,66.21,5556132
> 20,3173233,17.55,1072417,67.16,5848560
> 21,3209710,13.37,1079147,65.64,6140988
> 22,3182958,9.37,1085872,65.95,6433416
> 23,3200747,5.23,1076414,59.40,6725844
> 24,3181699,1.04,1051233,65.62,7018272
>
> Page-hinting:
> tasks,processes,processes_idle,threads,threads_idle,linear
> 0,0,100,0,100,0
> 1,467693,95.83,467970,95.83,467970
> 2,967860,91.68,895883,91.70,935940
> 3,1408191,87.53,1279602,87.68,1403910
> 4,1766250,83.39,1557224,83.93,1871880
> 5,2124689,79.24,1834625,80.35,2339850
> 6,2413514,75.10,1989557,77.00,2807820
> 7,2644648,70.95,2158055,73.73,3275790
> 8,2896483,66.81,2305785,70.85,3743760
> 9,3157796,62.67,2304083,69.49,4211730
> 10,3251633,58.53,2379589,66.43,4679700
> 11,3313704,54.41,2349310,64.76,5147670
> 12,3285612,50.30,2362013,62.63,5615640
> 13,3207275,46.17,2377760,59.94,6083610
> 14,3221727,42.02,2416278,56.70,6551580
> 15,3194781,37.91,2334552,54.96,7019550
> 16,3211818,33.78,2399077,52.75,7487520
> 17,3172664,29.65,2337660,50.27,7955490
> 18,3177152,25.49,2349721,47.02,8423460
> 19,3149924,21.36,2319286,40.16,8891430
> 20,3166910,17.30,2279719,43.23,9359400
> 21,3159464,13.19,2342849,34.84,9827370
> 22,3167091,9.06,2285156,37.97,10295340
> 23,3174137,4.96,2365448,33.74,10763310
> 24,3161629,0.86,2253813,32.38,11231280
>
>
> Test4: Netperf
> Guest size: 5GB
> Cores: 4
> Total NUMA Node Memory ~ 15 GB (All guests are running on a single node)
> Netserver: Running on core 0
> Netperf: Running on core 1
> Recv Socket Size bytes: 131072
> Send Socket Size bytes:16384
> Send Message Size bytes:1000000000
> Time: 900s
> Process: netperf is run 3 times sequentially in the same guest with the
> same inputs mentioned above and throughput (10^6bits/sec) is observed.
> unmodified kernel: 1st Run-14769.60, 2nd Run-14849.18, 3rd Run-14842.02
> bubble-hinting v1: 1st Run-13441.77, 2nd Run-13487.81, 3rd Run-13503.87
> Page-hinting: 1st Run-14308.20, 2nd Run-14344.36, 3rd Run-14450.07
>
> Drawback with bubble-hinting:
> More invasive.
>
> Drawback with page-hinting:
> Additional bitmap required, including growing/shrinking the bitmap on
> memory hotplug.
>
>
> [1] https://lkml.org/lkml/2019/6/19/926

Any chance you could provide a .config for your kernel? I'm wondering
what is different between the two as it seems like you are showing a
significant regression in terms of performance for the bubble
hinting/aeration approach versus a stock kernel without the patches
and that doesn't match up with what I have been seeing.

Also, any ETA for when we can look at the patches for the approach you have?

Thanks.

- Alex


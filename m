Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30FDEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 14:47:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A985B2133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 14:47:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=Mellanox.com header.i=@Mellanox.com header.b="yf2T8iKu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A985B2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=mellanox.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 27B008E0003; Thu, 28 Feb 2019 09:47:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 22CD48E0001; Thu, 28 Feb 2019 09:47:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CCC28E0003; Thu, 28 Feb 2019 09:47:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A90C48E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 09:47:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a9so8736877edy.13
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 06:47:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-transfer-encoding:mime-version;
        bh=ANWUvwh+6Z214uOhX598wP/7SG3RvlevvH+U0CBWE2o=;
        b=r6AZG65DPhL3zUCnIcR4VwdY++gAOp7dzLcMz/BmgjVDSs5vBy9KeEmVt1k1D+CEWY
         53Nc2OeJqP5PiC6k7epTb63lpuu12zHs41e6Kma5Z4MMeNa4VwQX2eOwReMsP08FUTt3
         1opDhCKoCNhnSZzby8pKnJSK1KDcSUpQFcRlsEkoj7Fipy3SIL7ONDPiXRk74UOSkyRz
         YtufQAOMECOqu7ZJbxRUPCNzSu9mLH5DYeawcNBpr1Z4oxZ0nrOE1ogSrJZeOfPKmW/t
         tEIwDyb5eqA5OA7B28QCpb4J1UDc4rMOlNNP8yY4yO4R1j2HIHY9bFeHzwogLAzYzM2D
         dkMQ==
X-Gm-Message-State: APjAAAUWS+W9p6ocVpYUFk1/lfirbrDGyUOdBneHtRZ+xl7qcYbrFWKO
	R4x2sozMZNmXoS2u/q1tK66jzdWyzErlH8pXmhZ6zVe6JvZSglvdBrCcpYk75duxur5c3bQC6X+
	QoQp8qsTNjlL2Qvcu2lPdNhENIGBBCTtm3soyDsSFhMA+mq1U5je4cUbc+uE/WsLiTw==
X-Received: by 2002:a50:ba32:: with SMTP id g47mr3359edc.42.1551365244137;
        Thu, 28 Feb 2019 06:47:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqyNyfXaWG6IYbtQWLCUZXajpOPEP8/0cGsroB9VAIu62qaxv91XevjmJu1TM91gY/HxDFcd
X-Received: by 2002:a50:ba32:: with SMTP id g47mr3286edc.42.1551365243065;
        Thu, 28 Feb 2019 06:47:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551365243; cv=none;
        d=google.com; s=arc-20160816;
        b=rmI6zbl0UQdU/1jZaGgOqDRUtjePLtHMoRsny854erj5c9P85PpIIXIpzbP4EgVgeu
         OeR48zRfvdYx2HRQ974P1d1/KGI/2EQUPhInnd2EZWn7DC+BaMnVu87mUlgpdx+hXlzj
         pwv2Ed4pAtsmCdgBejJm8bC9rEsji1oxec28MEGO+qF+VwgL8r80jfDh69HB9ScD/FAx
         RKN8vAycfMlhBW/Fi20jQgM/rInhupaYYsYi6oDGqEg6GIHgDrNqZJfRpNJqo1zjH5+W
         UHMUmucYovMxlwy+SxZAgv69ps8Jkg6Kt3pv7sMoBE8e98I9XoHdKJgYmRnBoGQHkalF
         exlg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=ANWUvwh+6Z214uOhX598wP/7SG3RvlevvH+U0CBWE2o=;
        b=H424Qg/WNslG4Fba7efVBmRVOcutvcq+hNUJvTjCPMhQF5531AixSj9jJxp1Sx9z++
         J7EU8vFTFi+MBHwj2vb4lJ6RNdaVWOzr9I4DCVMx2rGL0RpB/AvzT0O+N5DkzUBECPt6
         kebc2RmQAx7zN7+rWay5sX4eYGavJ7td7xo3t1uJ84eG+i61UDQ/nFGlUbw/3UJiT6TD
         ilYA7ZMTIWXcTs28w8wt0az6LRGDGx6S9QZEnvx4TWSL74j/9DKTKjqjsyK63bGvjC+T
         K2uTT5q3ukIdr5onRmkB/GbGulutAzg/VgzgrJnKtVTKHbLY9ukpdvLrdI3QLstjXOIq
         8yoA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=yf2T8iKu;
       spf=pass (google.com: domain of vladbu@mellanox.com designates 40.107.1.62 as permitted sender) smtp.mailfrom=vladbu@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10062.outbound.protection.outlook.com. [40.107.1.62])
        by mx.google.com with ESMTPS id w22si7455112edb.33.2019.02.28.06.47.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 06:47:23 -0800 (PST)
Received-SPF: pass (google.com: domain of vladbu@mellanox.com designates 40.107.1.62 as permitted sender) client-ip=40.107.1.62;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@Mellanox.com header.s=selector1 header.b=yf2T8iKu;
       spf=pass (google.com: domain of vladbu@mellanox.com designates 40.107.1.62 as permitted sender) smtp.mailfrom=vladbu@mellanox.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=mellanox.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=Mellanox.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ANWUvwh+6Z214uOhX598wP/7SG3RvlevvH+U0CBWE2o=;
 b=yf2T8iKuEiw+NuCDqp4rZGPDDPnF0ZhfPCYQptaM/oJje/LouRF7IFfQe25PvJGxnG+OuMsHj5diyyVpxooTuq2mSAcqjjCf5CJWeIlzgNb0hyaqkDMtuxM/xYP4HuOAD956ZsFqebL9ZyaKQtUxSS9yHYcUcRxHiC6k5IoE9Eg=
Received: from HE1PR0502MB3641.eurprd05.prod.outlook.com (10.167.127.11) by
 HE1PR0502MB3083.eurprd05.prod.outlook.com (10.175.30.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.15; Thu, 28 Feb 2019 14:47:20 +0000
Received: from HE1PR0502MB3641.eurprd05.prod.outlook.com
 ([fe80::b03d:8cd4:d259:f749]) by HE1PR0502MB3641.eurprd05.prod.outlook.com
 ([fe80::b03d:8cd4:d259:f749%5]) with mapi id 15.20.1643.019; Thu, 28 Feb 2019
 14:47:20 +0000
From: Vlad Buslov <vladbu@mellanox.com>
To: Dennis Zhou <dennis@kernel.org>
CC: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>,
	"kernel-team@fb.com" <kernel-team@fb.com>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>, "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 00/12] introduce percpu block scan_hint
Thread-Topic: [PATCH 00/12] introduce percpu block scan_hint
Thread-Index: AQHUz3SBmx1IgIX3kUia98qyyRxfXA==
Date: Thu, 28 Feb 2019 14:47:19 +0000
Message-ID: <vbfzhqgas25.fsf@mellanox.com>
References: <20190228021839.55779-1-dennis@kernel.org>
In-Reply-To: <20190228021839.55779-1-dennis@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-clientproxiedby: LO2P265CA0289.GBRP265.PROD.OUTLOOK.COM
 (2603:10a6:600:a5::13) To HE1PR0502MB3641.eurprd05.prod.outlook.com
 (2603:10a6:7:85::11)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=vladbu@mellanox.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [37.142.13.130]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 895c70ee-444d-4ba3-acab-08d69d8ba3ef
x-ms-office365-filtering-ht: Tenant
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(4618075)(2017052603328)(7153060)(7193020);SRVR:HE1PR0502MB3083;
x-ms-traffictypediagnostic: HE1PR0502MB3083:
x-ms-exchange-purlcount: 3
x-microsoft-exchange-diagnostics:
 =?iso-8859-1?Q?1;HE1PR0502MB3083;23:600GL1PGZdJY6rV+GQvzSw4SflsBaB0rM3l1z?=
 =?iso-8859-1?Q?y+egn06/RMOx2qlFE5V/YA6Y6J+dP21danWViAET9ujnU1Yi0RgFFU393e?=
 =?iso-8859-1?Q?en1XjtE9b0JyIJclAxWQDM1YoyHTbgIxYFgkR+TTILHPPVtNWKO2uyutJS?=
 =?iso-8859-1?Q?izjiCOekc4T4uL6UeEG4Ba5+k/tf/csonXQpyVMRWq4nfTrfyI+tWMQAJS?=
 =?iso-8859-1?Q?kyJWeywI/QT/7diLXgo0DrXctk7h2o4M4a2B5akItrzdDb5fClgH4iIl9v?=
 =?iso-8859-1?Q?/r6LCBm4jgT6H7DU7z31j1Yn2G/P7vjIzhi4P9umRYWQ3CI2zGt/MK1w5S?=
 =?iso-8859-1?Q?PsTY32imU+EOWAfBxIZspwmYjHh2Yoh6mjI6TpHHvLA4/qsB3rP+cyjYcy?=
 =?iso-8859-1?Q?vi0rjekRw+2srMqCKlY1PCTGqma02hne1+xD+2L1ht7wHT0U73MMzlhLsp?=
 =?iso-8859-1?Q?RXqMODGTJqJ6ilAwSsmzvFe6X5SZ+XQ5V41eJIMKI6+qVl4+fsERQDqV3Z?=
 =?iso-8859-1?Q?suKIaOBCLWvOwvjYQf+3CJZxBe6ZirEcpHNUIiCzJkomvpduFD1o/nKM4J?=
 =?iso-8859-1?Q?b8aFe/EvU8jsjmx7uwHq3vf8wgLCz0WLnmWvczQb3Yf+E7gejfByrm+1vY?=
 =?iso-8859-1?Q?5N4EHXm0hI5aZRf9IByRlJpv+8P2mxW1q38+DueJqyENtC3yDV2+3pfEn6?=
 =?iso-8859-1?Q?pUStsoHuTSxq+OvL5GJCZ/dQoEN6qeotv9HoS/SwomRBqKq+UyhtNQA1qQ?=
 =?iso-8859-1?Q?8VzSVf9e7tVc5I/uPPAQKetUcbru7rJLCIsZH+wHX6xd5SVFGh84GaB7JM?=
 =?iso-8859-1?Q?St7k+nezczjpBUPZ+deEmL3w/iSuycw6FZpzwaf4aih0MDenAHhoj9vxpB?=
 =?iso-8859-1?Q?tOUjgkANGaNELNmMawX+C6RWlvM1iX36ulRTJsPqGjwqEjJjmdGz5uscwU?=
 =?iso-8859-1?Q?chqMhE7dJcpmDcYgHGimYJHFZTroFBP/SYHgAi+VLToLCxFPJowy5ZcjjS?=
 =?iso-8859-1?Q?+OjlOxzibdwSejqaY1onx+fBd0/x4dgjl0h5XCrP6nPs4N+/xelgbJwGgu?=
 =?iso-8859-1?Q?fxcvT+15pvnlUEvA3AUEcTfQ8Yzk/oUMWFX6mpNd01IzIustktmWzvNbsp?=
 =?iso-8859-1?Q?NRh6O1dEfQWOxI0OP0BgqSYx7SGY7hdWJP60j3kqD89ZG/xhTWQtlQFFfN?=
 =?iso-8859-1?Q?nEIl/nvz8z46uHke/Qfd0RqGj9bwPO4oHq1IS0WqOjV7nXWiTag5XCBSgu?=
 =?iso-8859-1?Q?C3a6AI5R5iyd9ufYMGfeZuiy5/zBl25fLltTGDod/jUvO2CsbDtHh0obQr?=
 =?iso-8859-1?Q?JcYx1kaoDEwAFg6xYZYKMkRmVZdfuvQy/D3eSXoBegsH1tg=3D=3D?=
x-microsoft-antispam-prvs:
 <HE1PR0502MB308328544A21EDE0D3CA5703AD750@HE1PR0502MB3083.eurprd05.prod.outlook.com>
x-forefront-prvs: 0962D394D2
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(136003)(396003)(346002)(376002)(39860400002)(366004)(53754006)(189003)(199004)(26005)(86362001)(25786009)(6916009)(6116002)(71200400001)(71190400001)(68736007)(6486002)(3846002)(6436002)(6306002)(229853002)(53936002)(2906002)(4326008)(6512007)(6246003)(11346002)(36756003)(316002)(102836004)(66066001)(14454004)(14444005)(54906003)(256004)(106356001)(105586002)(966005)(478600001)(6506007)(386003)(5660300002)(8676002)(81156014)(99286004)(7736002)(81166006)(305945005)(2616005)(476003)(97736004)(8936002)(446003)(52116002)(76176011)(186003)(486006);DIR:OUT;SFP:1101;SCL:1;SRVR:HE1PR0502MB3083;H:HE1PR0502MB3641.eurprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: mellanox.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 f1ls7C06UBiuQI/kum5VFMafFWMG0N4D+7wHWOIlwQ3P498E3+gSAld2pTROEluK+AG5ls14uds0mZZQ3F+cwPYVfZSkcToABYnp5GRhx/PupaNns1laUWBsgX7aEpZAgphWi/gedTpwiSxlVndy0BVXEGZWxtBriXFSaGw3nYh3STXHSZ5jswoLqIS59qQm4GPSLqaw+A57KkSkteHubFpcolkizRoi7Sg52bDI6UiaPYCw5c5C28xyKVD9x+4ldxd5mBJ4ohaIXCZjW8G8NTRJ/4uFaGeYDJYfQUk8uOsBTTUuLwwQCfggZ80026KyheuxEqWTSfCr+AACluQeF08KBQoInjSmO8KfkBgofZpPJ351yUzTGZLkfoJsFRQmpLGPnJSVPgEpYVc8kvTpx5py89J24gdTuIodZgpqQqs=
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: Mellanox.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 895c70ee-444d-4ba3-acab-08d69d8ba3ef
X-MS-Exchange-CrossTenant-originalarrivaltime: 28 Feb 2019 14:47:18.6916
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: a652971c-7d2e-4d9b-a6a4-d149256f461b
X-MS-Exchange-Transport-CrossTenantHeadersStamped: HE1PR0502MB3083
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu 28 Feb 2019 at 02:18, Dennis Zhou <dennis@kernel.org> wrote:
> Hi everyone,
>
> It was reported a while [1] that an increase in allocation alignment
> requirement [2] caused the percpu memory allocator to do significantly
> more work.
>
> After spending quite a bit of time diving into it, it seems the crux was
> the following:
>   1) chunk management by free_bytes caused allocations to scan over
>      chunks that could not fit due to fragmentation
>   2) per block fragmentation required scanning from an early first_free
>      bit causing allocations to repeat work
>
> This series introduces a scan_hint for pcpu_block_md and merges the
> paths used to manage the hints. The scan_hint represents the largest
> known free area prior to the contig_hint. There are some caveats to
> this. First, it may not necessarily be the largest area as we do partial
> updates based on freeing of regions and failed scanning in
> pcpu_alloc_area(). Second, if contig_hint =3D=3D scan_hint, then
> scan_hint_start > contig_hint_start is possible. This is necessary
> for scan_hint discovery when refreshing the hint of a block.
>
> A necessary change is to enforce a block to be the size of a page. This
> let's the management of nr_empty_pop_pages to be done by breaking and
> making full contig_hints in the hint update paths. Prior, this was done
> by piggy backing off of refreshing the chunk contig_hint as it performed
> a full scan and counting empty full pages.
>
> The following are the results found using the workload provided in [3].
>
>         branch        | time
>        ------------------------
>         5.0-rc7       | 69s
>         [2] reverted  | 44s
>         scan_hint     | 39s
>
> The times above represent the approximate average across multiple runs.
> I tested based on a basic 1M 16-byte allocation pattern with no
> alignment requirement and times did not differ between 5.0-rc7 and
> scan_hint.
>
> [1] https://lore.kernel.org/netdev/CANn89iKb_vW+LA-91RV=3DzuAqbNycPFUYW54=
w_S=3DKZ3HdcWPw6Q@mail.gmail.com/
> [2] https://lore.kernel.org/netdev/20181116154329.247947-1-edumazet@googl=
e.com/
> [3] https://lore.kernel.org/netdev/vbfzhrj9smb.fsf@mellanox.com/
>
> This patchset contains the following 12 patches:
>   0001-percpu-update-free-path-with-correct-new-free-region.patch
>   0002-percpu-do-not-search-past-bitmap-when-allocating-an-.patch
>   0003-percpu-introduce-helper-to-determine-if-two-regions-.patch
>   0004-percpu-manage-chunks-based-on-contig_bits-instead-of.patch
>   0005-percpu-relegate-chunks-unusable-when-failing-small-a.patch
>   0006-percpu-set-PCPU_BITMAP_BLOCK_SIZE-to-PAGE_SIZE.patch
>   0007-percpu-add-block-level-scan_hint.patch
>   0008-percpu-remember-largest-area-skipped-during-allocati.patch
>   0009-percpu-use-block-scan_hint-to-only-scan-forward.patch
>   0010-percpu-make-pcpu_block_md-generic.patch
>   0011-percpu-convert-chunk-hints-to-be-based-on-pcpu_block.patch
>   0012-percpu-use-chunk-scan_hint-to-skip-some-scanning.patch
>
> 0001 fixes an issue where the chunk contig_hint was being updated
> improperly with the new region's starting offset and possibly differing
> contig_hint. 0002 fixes possibly scanning pass the end of the bitmap.
> 0003 introduces a helper to do region overlap comparison. 0004 switches
> to chunk management by contig_hint rather than free_bytes. 0005 moves
> chunks that fail to allocate to the empty block list to prevent excess
> scanning with of chunks with small contig_hints and poor alignment.
> 0006 introduces the constraint PCPU_BITMAP_BLOCK_SIZE =3D=3D PAGE_SIZE an=
d
> modifies nr_empty_pop_pages management to be a part of the hint updates.
> 0007-0009 introduces percpu block scan_hint. 0010 makes pcpu_block_md
> generic so chunk hints can be managed as a pcpu_block_md responsible
> for more bits. 0011-0012 add chunk scan_hints.
>
> This patchset is on top of percpu#master a3b22b9f11d9.
>
> diffstats below:
>
> Dennis Zhou (12):
>   percpu: update free path with correct new free region
>   percpu: do not search past bitmap when allocating an area
>   percpu: introduce helper to determine if two regions overlap
>   percpu: manage chunks based on contig_bits instead of free_bytes
>   percpu: relegate chunks unusable when failing small allocations
>   percpu: set PCPU_BITMAP_BLOCK_SIZE to PAGE_SIZE
>   percpu: add block level scan_hint
>   percpu: remember largest area skipped during allocation
>   percpu: use block scan_hint to only scan forward
>   percpu: make pcpu_block_md generic
>   percpu: convert chunk hints to be based on pcpu_block_md
>   percpu: use chunk scan_hint to skip some scanning
>
>  include/linux/percpu.h |  12 +-
>  mm/percpu-internal.h   |  15 +-
>  mm/percpu-km.c         |   2 +-
>  mm/percpu-stats.c      |   5 +-
>  mm/percpu.c            | 547 +++++++++++++++++++++++++++++------------
>  5 files changed, 404 insertions(+), 177 deletions(-)
>
> Thanks,
> Dennis

Hi Dennis,

Thank you very much for doing this!

I applied the patches on top of current net-next and can confirm that tc
filter insertion rate is significantly improved and is better compared
to version with offending commit simply reverted.

Regards,
Vlad


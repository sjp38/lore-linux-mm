Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD17EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:37:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89C1B2054F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 20:37:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="WDv4wpdP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89C1B2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B37B6B0007; Wed, 27 Mar 2019 16:37:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 337906B0008; Wed, 27 Mar 2019 16:37:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B1806B000A; Wed, 27 Mar 2019 16:37:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D1FD96B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 16:37:49 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id h69so14863339pfd.21
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 13:37:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:dkim-signature;
        bh=h36SjGYinWxbAr88VzsF+G4sIWd6jVLSJPZTBRLBtF4=;
        b=G6EGCbkn7KTfC2wDLrWI3AFutQmv4093g6RzFKJpsJ/Z/set51iYmF7tlfhyFiiUMD
         IyWV+7y2sFckQ5o+7AYmF/xwTsx2KMWEn6zKMO/teWiImsFiqEiWNO4UvSRPXQFxD63v
         g2jBWvoYjMzO+VLa/GDNo2QLt0yuTIHWYXXi//iP7N9l0mpt/xeka4v0wQOP11alnXOb
         B7jXVDaJCGAQByNuWHTAF8Uiv+ZGjz572q0YbkXnbqxPJ3873oJeLw321QCbAGdeTfP1
         yC1bUvGsMPFsvZkuyOhGcHjmjn/Xw373Sqy8v6hqkZRAMcCwQN9WIjuq3mb4tnDeiInY
         wnrA==
X-Gm-Message-State: APjAAAWzxFX+DWtXrSMRnTiT3hNnWPDJwtu6GtivAMq33mkgoMGxR7mg
	11QfHQqLCrHYaePnjFV6TJ68w/cB9zG0DHlT5LrkyAG0EnF/qI1SJRPlUAi2kXXxzd8uCBqXjxl
	9OW61H0gAFrKUUo2gEjNQHTxsFLx3LxJ7QIUj8ggqrrh6gxemf1aw9gf+5/3sN9IuVA==
X-Received: by 2002:a63:450f:: with SMTP id s15mr35675937pga.157.1553719069497;
        Wed, 27 Mar 2019 13:37:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIrVyHwRT/kwle3XbqKmFgql4meFELuR4QUgfRivKs53EXk5y5SGIxB9Hw1m2JSeAglSUZ
X-Received: by 2002:a63:450f:: with SMTP id s15mr35675897pga.157.1553719068579;
        Wed, 27 Mar 2019 13:37:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553719068; cv=none;
        d=google.com; s=arc-20160816;
        b=aDFWw0cKPAcGZ2AhXlKcvQ39Lh1h78QQw4ajhCBcMymZnDuzJDwuluGl7D30iBAHIL
         tTNvHTwfXLKkPrsuQosikAG+ipbaLankorlZC5nWY1iGeRMkMMP08MU5EAIl9xh+xWys
         xUe2seONuWl9UxtXuzZ4lYMvKX8s+mbcv1ejfU5rTxM3MpLBY4mEM74AW5clHWzMRAwR
         NHjGA1xMN2pjwK8H47vN0H27sdXjabmpkfmRuVYC0edfrf98nJNYIHpZElO8jF8QgUsh
         9+S75EOtYQjejVDH1fxD11Kxg0ei+DmNwT5ppDOu9IUm2l9HlAZZuD8Yvhh03RZpJ1pj
         zKcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from;
        bh=h36SjGYinWxbAr88VzsF+G4sIWd6jVLSJPZTBRLBtF4=;
        b=GF8JmcupKYhSXHLEBOA3gk9mx1+EFPQt4SI4Uj1xj2iE+XrvutY6FYybK8Vu9pwgSY
         BoUDPKPDsjTGvheQApsBML2G8dnqIqoZ9TJQ3IfIrjFyYv8c/+ynOv6c+zeyYSn/whLP
         qWQ5WE8xlgcPXUGbL+rMC4O05qgVqxscS1SwkyFiaQuFC9CoXbwmMbD1YJZDgMP/rXiT
         M39DjHK+7E8qKBTrikCVU5+TAtoLLG/C38E6jf1Nf4q3ExJ5Nad607Km+BMmLwRCVDA/
         qwafkrq72qsSj8cLQCSixkAz9HDNotcSrpZL65+pmk2wXT1GIeBPEHYv2fw4U0qbqe7Y
         VmAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WDv4wpdP;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id k24si4095214pfk.284.2019.03.27.13.37.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 13:37:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=WDv4wpdP;
       spf=pass (google.com: domain of ziy@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=ziy@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c9bdf160000>; Wed, 27 Mar 2019 13:37:42 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Wed, 27 Mar 2019 13:37:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Wed, 27 Mar 2019 13:37:47 -0700
Received: from [10.2.162.144] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 27 Mar
 2019 20:37:47 +0000
From: Zi Yan <ziy@nvidia.com>
To: Dave Hansen <dave.hansen@intel.com>
CC: Keith Busch <kbusch@kernel.org>, Yang Shi <yang.shi@linux.alibaba.com>,
	<mhocko@suse.com>, <mgorman@techsingularity.net>, <riel@surriel.com>,
	<hannes@cmpxchg.org>, <akpm@linux-foundation.org>, "Busch, Keith"
	<keith.busch@intel.com>, "Williams, Dan J" <dan.j.williams@intel.com>, "Wu,
 Fengguang" <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>, "Huang,
 Ying" <ying.huang@intel.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Date: Wed, 27 Mar 2019 13:37:46 -0700
X-Mailer: MailMate (1.12.4r5622)
Message-ID: <6A903D34-A293-4056-B135-6FA227DE1828@nvidia.com>
In-Reply-To: <3fd20a95-7f2d-f395-73f6-21561eae9912@intel.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
 <2C32F713-2156-4B58-B5C1-789C1821EBB9@nvidia.com>
 <de044f93-c4e8-8b8b-9372-e15ca74e7696@intel.com>
 <33FCCD53-4A4D-4115-9AC3-6C35A300169F@nvidia.com>
 <3fd20a95-7f2d-f395-73f6-21561eae9912@intel.com>
MIME-Version: 1.0
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: multipart/signed;
	boundary="=_MailMate_2BEEEC6C-1579-462B-8F1F-950E33DD9DA3_=";
	micalg=pgp-sha1; protocol="application/pgp-signature"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553719062; bh=h36SjGYinWxbAr88VzsF+G4sIWd6jVLSJPZTBRLBtF4=;
	h=X-PGP-Universal:From:To:CC:Subject:Date:X-Mailer:Message-ID:
	 In-Reply-To:References:MIME-Version:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type;
	b=WDv4wpdPTmvMVsOp5DLAZLpm1eO2fYzW5JwqOM/b7eWwEP0/j4paEshOSfmkoAlHm
	 eWSwPOBGBekT0YMn+yix5ksiQfFB4lxpo5K9NWCAUK9a9eM+vpRupSBX9KRn6BaM/p
	 CSH7jrbSXyK8/N3g/1krBo36Z/Uex/gl7ekFeo29beNQXjcoc+OCfNnxpPmeC7pEpu
	 51cw6tucUDRg1nxIJWVJ5uNcUyBmpa7qc2djucHG1bL8GTP2N6mxPXbsIIYxMuopaG
	 y62jS5H5ZNnargM9K/r3zrgJd+9tMef49GIbFk8uond+joeC8MXzCOnR0byygSLv4l
	 yhOapVQn6ypNA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--=_MailMate_2BEEEC6C-1579-462B-8F1F-950E33DD9DA3_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 27 Mar 2019, at 11:00, Dave Hansen wrote:

> On 3/27/19 10:48 AM, Zi Yan wrote:
>> For 40MB/s vs 750MB/s, they were using sys_migrate_pages(). Sorry
>> about the confusion there. As I measure only the migrate_pages() in
>> the kernel, the throughput becomes: migrating 4KB page: 0.312GB/s
>> vs migrating 512 4KB pages: 0.854GB/s. They are still >2x
>> difference.
>>
>> Furthermore, if we only consider the migrate_page_copy() in
>> mm/migrate.c, which only calls copy_highpage() and
>> migrate_page_states(), the throughput becomes: migrating 4KB page:
>> 1.385GB/s vs migrating 512 4KB pages: 1.983GB/s. The gap is
>> smaller, but migrating 512 4KB pages still achieves 40% more
>> throughput.
>>
>> Do these numbers make sense to you?
>
> Yes.  It would be very interesting to batch the migrations in the
> kernel and see how it affects the code.  A 50% boost is interesting,
> but not if it's only in microbenchmarks and takes 2k lines of code.
>
> 50% is *very* interesting if it happens in the real world and we can
> do it in 10 lines of code.
>
> So, let's see what the code looks like.

Actually, the migration throughput difference does not come from any kern=
el
changes, it is a pure comparison between migrate_pages(single 4KB page) a=
nd
migrate_pages(a list of 4KB pages). The point I wanted to make is that
Yang=E2=80=99s approach, which migrates a list of pages at the end of shr=
ink_page_list(),
can achieve higher throughput than Keith=E2=80=99s approach, which migrat=
es one page
at a time in the while loop inside shrink_page_list().

In addition to the above, migrating a single THP can get us even higher t=
hroughput.
Here is the throughput numbers comparing all three cases:
                             |  migrate_page()  |    migrate_page_copy()
migrating single 4KB page:   |  0.312GB/s       |   1.385GB/s
migrating 512 4KB pages:     |  0.854GB/s       |   1.983GB/s
migrating single 2MB THP:    |  2.387GB/s       |   2.481GB/s

Obviously, we would like to migrate THPs as a whole instead of 512 4KB pa=
ges
individually. Of course, this assumes we have free space in PMEM for THPs=
 and
all subpages in the THPs are cold.


To batch the migration, I posted some code a while ago: https://lwn.net/A=
rticles/714991/,
which show good throughput improvement for microbenchmarking sys_migrate_=
page().
It also included using multi threads to copy a page, aggregate multiple m=
igrate_page_copy(),
and even using DMA instead of CPUs to copy data. We could revisit the cod=
e if necessary.

In terms of end-to-end results, I also have some results from my paper:
http://www.cs.yale.edu/homes/abhishek/ziyan-asplos19.pdf (Figure 8 to Fig=
ure 11 show the
microbenchmark result and Figure 12 shows end-to-end results). I basicall=
y called
shrink_active/inactive_list() every 5 seconds to track page hotness and u=
sed all my page
migration optimizations above, which can get 40% application runtime spee=
dup on average.
The experiments were done in a two-socket NUMA machine where one node was=
 slowed down to
have 1/2 BW and 2x access latency, compared to the other node. I can disc=
uss about it
more if you are interested.


--
Best Regards,
Yan Zi

--=_MailMate_2BEEEC6C-1579-462B-8F1F-950E33DD9DA3_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQJDBAEBAgAtFiEEh7yFAW3gwjwQ4C9anbJR82th+ooFAlyb3xoPHHppeUBudmlk
aWEuY29tAAoJEJ2yUfNrYfqK1UMP/1Pd0ozYIfrQ0JNoHBz4zGr3O71WjEcSr08P
CUb/SsBmh03a2LXJKCy5hcR89ihFzdXKQ+/iqhwagUyGZic0ocOzABh/KikFqnKV
nRtenfr3v62erGE955BWGZZxoKlzOeP3zkdL6qbKH8qXtB79cj835HTN+P9U+mUH
d1+0eCB8i3F0xS/BMyVn5e44p2mKuNOYFIY+vSjO2XISVr9lLjYJa7LiGTvIHqgP
R/QtPqP7wULvOS2xJ4HPAQ0TR3QDJs5obgekwJqjxHX+38B6FCLQ7bR5nsUrJyAT
4UDNEAl9ano9aZtaVfDr9My9zuAaZQwlHvwfhfmYhos+e+Vf2vjx9XZy3Mubo0eE
co0nrQUb9oKP88ACfaXI2Nqsa+/ctQQdkITiEHWxMQhtFvq5VcHwir5oBIG/Ylhv
6WwwYmSBlQoYC5TibSHMcpqjr1XGZU1UHEBtobqngrPlcvFYyuQrqqScoPYgi8vf
vFATQt1Goqwiky0+0vlazCmVzNIALxbZ4WqsmmDSY+SvoJ3QOtnaG26szOhgvGv+
0knzMccufS2QNwXuxJyiWzoKmlGpGNklkNcVQkPsSmMMXvdrwImn2aVII9MFoZ8H
kjDLEyYY29BzhwYLk28Yz0ijXb7zaNVD+DGS3WBf052aGMPwDTEbrETe+1Q9pzpW
HFCg5iF5
=lzxQ
-----END PGP SIGNATURE-----

--=_MailMate_2BEEEC6C-1579-462B-8F1F-950E33DD9DA3_=--


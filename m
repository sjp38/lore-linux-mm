Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4063C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:19:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78E1C2075E
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 12:19:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78E1C2075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11B0B6B000A; Tue, 26 Mar 2019 08:19:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A4386B000C; Tue, 26 Mar 2019 08:19:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89216B000D; Tue, 26 Mar 2019 08:19:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f198.google.com (mail-oi1-f198.google.com [209.85.167.198])
	by kanga.kvack.org (Postfix) with ESMTP id B10746B000A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 08:19:25 -0400 (EDT)
Received: by mail-oi1-f198.google.com with SMTP id d198so5173626oih.6
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 05:19:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=o1ht0cQu1vSLbWCzodaXG4J3SvluOY114GeXiFATVng=;
        b=Pd7+HCFHEEOGJVgmsrYfAvCU/chm2eQzzSpBp3LDdG8T0abp6u0elkTB21OWd3/u4G
         I/kKkYOnw/RjYabJv4TWG6/39JTscpUNawQ40xg3VqY0frqihZOkHkG546MI9wHXVQBC
         tPmTGZPqSp+q96o09n2PW9JrIsenrQ7pU+CHJgl9O1xTD4HivMinWbyR+j96IZEl7oKn
         Jws8JnP2aYKLZZTGnLXeVGLMlAz/AVKkX/WQzH/wCGkJi38nozxzvugsy0rMxanu+iey
         uzwkhVllKiDuqqcBNnyltKPV/GMiK9z134MOsbujbpZS6jpjQgjoNcBR49PwrbyEU2op
         7CdQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAXEFbkrYZ46Azv3St7B2mX2GDfrHoeQIJgk9BmPc5H63bt7yGoE
	GHN6hTsGD279qSTViivrEL7YmYXed3uY+wgOFRzx9MDJYGa++mPvZFZgdh19ZWj+WLYUU5ydLBD
	UicQSiIFHBD32RV4lKb31RDlGird5kK5/aQLjL1dhMARdAZu8ZUbS1Jvwbf6q22UtjQ==
X-Received: by 2002:aca:5809:: with SMTP id m9mr15536329oib.88.1553602765386;
        Tue, 26 Mar 2019 05:19:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvYIY0FnW2dKsnB814xIEwyJOOMK3x4o8KoVEBsGxaJxOE+Lna1nQ6Nfp2Ve1sSoSQNSIj
X-Received: by 2002:aca:5809:: with SMTP id m9mr15536295oib.88.1553602764768;
        Tue, 26 Mar 2019 05:19:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553602764; cv=none;
        d=google.com; s=arc-20160816;
        b=A9XKu6iFeQ7G6coKTDn0g8LR0RwhBSzZGtz2MagZnK/enDnvfnyzsv2/AdHMe4FzUF
         M0Ygjx1Evnw197jFcwRd4wAjtcEvfI0T/toAmuApBsRnBlLgQNCSiQzs26VecBLNOP9R
         MGNUM7b23+B2V3jFy2q5VSo8x/zUhkvmUXjSRZ/c9ye5bfgWEGysNFIXRjAGJxFuu6mU
         z1yqtUCytql3oSd9VABdZG5DKM2WxkhFN2CcwszP5UzF0EgczviSURwC7Cp9WxSfBBW2
         hdXluYFqau6e2CqT9n6hOrZ2aNfcd8+2r+3Vh1G6xyKrFse6PApk21LoxpjFIkuFytTG
         oW/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=o1ht0cQu1vSLbWCzodaXG4J3SvluOY114GeXiFATVng=;
        b=Ztoz2rdnTSq+CjwyrjAk1BtUiLqUyY3KAGJqUiTf3Pf+upOmcdSnGp10utERDxf3fw
         7c02vpIzYB7KeKrXWEc5n3RX1xgTl+id9+zupQxeDxZ1W6B7po3WgOKRzCaJH8JeCt0N
         LEoFqed0J+4krZPzDuiDO+y2Cl/TCarnSeCXw87C7+/lfQUMpQY7buUYaKJSa3hTcAru
         Quo/1zz97IKKzjrBA84GvbI8Tr8KQHwhyhqalRuBLtfuprq3cEomqp0i1Q7m09jAAKXm
         FqaHoTRcht9BoqRt881yrLxdZb5YEmo4TMBaxh0Dtiz+/TtKdD6l1zfqEJ9m5P7odzjb
         2r9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id d39si8498402otb.55.2019.03.26.05.19.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 05:19:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 6F422EBD771C26ABBC51;
	Tue, 26 Mar 2019 20:19:19 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.408.0; Tue, 26 Mar 2019
 20:19:17 +0800
Date: Tue, 26 Mar 2019 12:19:02 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Dan Williams <dan.j.williams@intel.com>
CC: Brice Goglin <Brice.Goglin@inria.fr>, Yang Shi
	<yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@suse.com>, Mel Gorman
	<mgorman@techsingularity.net>, Rik van Riel <riel@surriel.com>, "Johannes
 Weiner" <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>,
	"Dave Hansen" <dave.hansen@intel.com>, Keith Busch <keith.busch@intel.com>,
	Fengguang Wu <fengguang.wu@intel.com>, "Du, Fan" <fan.du@intel.com>, "Huang,
 Ying" <ying.huang@intel.com>, Linux MM <linux-mm@kvack.org>, "Linux Kernel
 Mailing List" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190326121902.00004f10@huawei.com>
In-Reply-To: <CAPcyv4imk02wme0PsY0rUePax8SOq2-=+objYT-x4bxthLkKkQ@mail.gmail.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
	<cc6f44e2-48b5-067f-9685-99d8ae470b50@inria.fr>
	<CAPcyv4it1w7SdDVBV24cRCVHtLb3s1pVB5+SDM02Uw4RbahKiA@mail.gmail.com>
	<3df2bf0e-0b1d-d299-3b8e-51c306cdc559@inria.fr>
	<CAPcyv4gNrFOQJhKUV7crZqNfg8LQFZRVO04Z+Fo50kzswVQ=TA@mail.gmail.com>
	<ac409eac-d2fa-8e93-6a18-14516b05632f@inria.fr>
	<CAPcyv4imk02wme0PsY0rUePax8SOq2-=+objYT-x4bxthLkKkQ@mail.gmail.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Mar 2019 16:37:07 -0700
Dan Williams <dan.j.williams@intel.com> wrote:

> On Mon, Mar 25, 2019 at 4:09 PM Brice Goglin <Brice.Goglin@inria.fr> wrot=
e:
> >
> >
> > Le 25/03/2019 =E0 20:29, Dan Williams a =E9crit : =20
> > > Perhaps "path" might be a suitable replacement identifier rather than
> > > type. I.e. memory that originates from an ACPI.NFIT root device is
> > > likely "pmem". =20
> >
> >
> > Could work.
> >
> > What kind of "path" would we get for other types of memory? (DDR,
> > non-ACPI-based based PMEM if any, NVMe PMR?) =20
>=20
> I think for memory that is described by the HMAT "Reservation hint",
> and no other ACPI table, it would need to have "HMAT" in the path. For
> anything not ACPI it gets easier because the path can be the parent
> PCI device.
>=20

There is no HMAT reservation hint in ACPI 6.3 - but there are other ways
of doing much the same thing so this is just a nitpick.

J


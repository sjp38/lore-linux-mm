Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 017F2C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:25:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7AB9216C4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 17:25:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="h+8kfPwU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7AB9216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51DD66B0005; Fri, 17 May 2019 13:25:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4CD9F6B0006; Fri, 17 May 2019 13:25:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 395A56B0008; Fri, 17 May 2019 13:25:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAC4D6B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 13:25:02 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id r48so11650818eda.11
        for <linux-mm@kvack.org>; Fri, 17 May 2019 10:25:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=KwxwPmgRkigdfsb2Wkb3RXFjzIqZbXV/qcyPm1HcIzw=;
        b=auqBr/vFk59zpBZZoczOahMKSzysB+RiHdP1ySdPTtNZUEY+qPZPrfqdB6ndsyaALC
         mtpU38Ak8oT0gy9xtXOKZtGfd6akDfc/uoNrK4pX7SnJJP3BgkB2YBIM0J8mmtBDkzww
         0U753zSxjVR7kUBM3XZa3LyT4w4puGkiPof4Zu93II47XKdEZ5hWGSsUuveq3OMrs5v9
         Wc9tCms3ultJ6Tk4CX5jqqwPuTB90TVkbok60j7901RA0P8VpxX3cFQv5QT+fyG/6G6H
         tZd9d+/MO7paA+NXmq/0uR7ruWnI6tOTkqRb+C7QWkJ/hMuwKxR5CPUIBd0lcsh4ANW2
         XQGg==
X-Gm-Message-State: APjAAAXqasvJF9ICWnERpVm1i+BAk5Syc6UTPh/uonBaLISQ54uofhb/
	xrd5H7wJldR6aaEI+kDfY05w/DCsAFUKytO4IpKO8W/8rUJP1GL3rWEtIPxx/sOFhBpoPBml+5t
	E6jJ9v/ASzNQ6LyhPrfuYUCBZNLtNncy7wMxbe9CNaxXlv4SVtrv0I1pMWD/SPdQYSw==
X-Received: by 2002:a50:a535:: with SMTP id y50mr59270030edb.249.1558113902399;
        Fri, 17 May 2019 10:25:02 -0700 (PDT)
X-Received: by 2002:a50:a535:: with SMTP id y50mr59269975edb.249.1558113901833;
        Fri, 17 May 2019 10:25:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558113901; cv=none;
        d=google.com; s=arc-20160816;
        b=d31KAYhHvTmtCwH96VtFrclXQ2F3FYUUjTEoERtrnnmfTbxmF903Hdit4EL95zStdo
         tEEDSoFyd1EAjEBiRUaDAW1hiYXXzsYwgU9uiDGLNwGQWqxHKbIH5cO/BgjPXaEPCyxg
         zOGQnPkFQQE9rVkElXoa4DUR9DJYLtYbeyCoOVcRjT5R/+0G2k7CQroU9EZRnF9AztXN
         WnES/PXh32j2VWgGwIwQW9gW5u0L0aQ9Dtsn1r73ZoDsK/1LkOBz2vBoDIZo1/EIbJT2
         ORdxeuJwdeVo8ybb6KBtE8/dzTImxVitJ28iHeWixzaUMkyvKpM/enCeqgxWrtD49QiH
         KXHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=KwxwPmgRkigdfsb2Wkb3RXFjzIqZbXV/qcyPm1HcIzw=;
        b=CDeuW8gULiKIF92I2QhRddpW+1wvOcUQ7v2KgKxhMNUGf9L1tooFJuETPSd0hVNfen
         R3TBrUHrAyzSGvzSiz5gDQQ+hjbvkUYJ+VF28rpPspzLd2FnHft6kNZmb1UsBCJZ1iXx
         JobV9gRaYcmy891eIXUWVkgJkHcaFEcgiu/GOxaYXVq9R1qjKU9GQ1Y4WoCSpZ9c4aE7
         R77e4BgpIBjyoilo/ejVyTRSSyly6UuqN154DEG+nh9AmdOLQbLCUgd0v4qQ62FWJx08
         dvWk4Sfwst1v5SMIUS7Jz4UYzKK7sEKo4WdFnkrA2W24HB7AOUf67ITUH4wvm2PXFjEY
         6BPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=h+8kfPwU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b2sor8314660edd.17.2019.05.17.10.25.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 May 2019 10:25:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=h+8kfPwU;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=KwxwPmgRkigdfsb2Wkb3RXFjzIqZbXV/qcyPm1HcIzw=;
        b=h+8kfPwUUJsUPbqk+gDlpRaeblBYE2fVW4Jl93m9L3oQKmknNCCYpao0UAd7gBMUks
         hPvzLnV7CdDh1/rNOvJ7v46flOg1P7P7cz6XzbCBCYHErwbjvAFHO8kAhowextIXP4K4
         wzyiG8+QdxKuZNzJAzTPlvWNsDUXruxytbe9VLr0sdzVqplAx0E4U5nvXrgAe4wbMxl6
         QCdQFy8r/2NXOgZ7Bbo8ZNYPwRVsY0c/6q0Ka037S0t7VHH6Oc7AMl/o6AVCy4Fohq/H
         1yjg5kwJzWMAQJFZgNugwf1zgUhfH+A3fbYIKv1b5n1rqomPr0aaze9q+ODnrQSUr8zZ
         LBbg==
X-Google-Smtp-Source: APXvYqwuyoSofrRAesux3TtniZbFtgeLGQpt/aaMsVyOQkqGRmuP2nmCLcnqBJYgiPbnM95G5HbA4GXqURtKw0f2SUc=
X-Received: by 2002:a50:ec87:: with SMTP id e7mr58594743edr.126.1558113901537;
 Fri, 17 May 2019 10:25:01 -0700 (PDT)
MIME-Version: 1.0
References: <CA+CK2bBeOJPnnyWBgj0CJ7E1z9GVWVg_EJAmDs07BSJDp3PYfQ@mail.gmail.com>
 <20190517143816.GO6836@dhcp22.suse.cz> <CA+CK2bA+2+HaV4GWNUNP04fjjTPKbEGQHSPrSrmY7HLD57au1Q@mail.gmail.com>
In-Reply-To: <CA+CK2bA+2+HaV4GWNUNP04fjjTPKbEGQHSPrSrmY7HLD57au1Q@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Fri, 17 May 2019 13:24:50 -0400
Message-ID: <CA+CK2bDq+2qu28afO__4kzO4=cnLH1P4DcHjc62rt0UtYwLm0A@mail.gmail.com>
Subject: Re: NULL pointer dereference during memory hotremove
To: Michal Hocko <mhocko@kernel.org>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, 
	"tiwai@suse.de" <tiwai@suse.de>, "sashal@kernel.org" <sashal@kernel.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "david@redhat.com" <david@redhat.com>, 
	"bp@suse.de" <bp@suse.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, "Jiang, Dave" <dave.jiang@intel.com>, 
	"bhelgaas@google.com" <bhelgaas@google.com>, "Busch, Keith" <keith.busch@intel.com>, 
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	"Wu, Fengguang" <fengguang.wu@intel.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 1:22 PM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> On Fri, May 17, 2019 at 10:38 AM Michal Hocko <mhocko@kernel.org> wrote:
> >
> > On Fri 17-05-19 10:20:38, Pavel Tatashin wrote:
> > > This panic is unrelated to circular lock issue that I reported in a
> > > separate thread, that also happens during memory hotremove.
> > >
> > > xakep ~/x/linux$ git describe
> > > v5.1-12317-ga6a4b66bd8f4
> >
> > Does this happen on 5.0 as well?
>
> Yes, just reproduced it on 5.0 as well. Unfortunately, I do not have a
> script, and have to do it manually, also it does not happen every
> time, it happened on 3rd time for me.

Actually, sorry, I have not tested 5.0, I compiled 5.0, but my script
still tested v5.1-12317-ga6a4b66bd8f4 build. I will report later if I
am able to reproduce it on 5.0.

Pasha


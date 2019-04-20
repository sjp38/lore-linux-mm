Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A653EC282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:30:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58C3920869
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 16:30:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="M1iwu9ox"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58C3920869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E35AA6B0007; Sat, 20 Apr 2019 12:30:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE5BC6B0008; Sat, 20 Apr 2019 12:30:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CFA776B000A; Sat, 20 Apr 2019 12:30:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C70E6B0007
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 12:30:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k56so4202271edb.2
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 09:30:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RZD2TOJdguYske3XdmnLmIq3XfcXZwBSYG0QJWjhaWk=;
        b=rt+uzoRW97QroBrJ30enhERMxI+t0E0CZciOQVO4euj3HC2X+KiQp0qGOIe4CsflNG
         +FoSWhHIQqwiqcAcmqjuM2g/s0LkE3ND7zd10DAJlB6v6aYsbyJOR46qB2QJm9BK8v9f
         uDAyt330iipv7sxhm/N5F0JgoMOyvdd20Y39nWs7RGKhm0rJvmkJ9+csaJdv1VHNsmUG
         UqE5Gcw7Po9XjBp9HFWFMfpQWwN93djzSCOlmTe9C4FN9DdkCgllmit1XShU6OPKNAUh
         mI7tYNaPml3qrrpwzsxbMxYNYCo1f8zlG+ABtXNOlN9FwUc8VQRX4GgSGPCa16RPuh4A
         RT6Q==
X-Gm-Message-State: APjAAAXJ4t6Ss9Ctu/T9dbGzkLOyRxKTVuPviaBT7ykCBIgh/qMe9JOQ
	0yq/p6pbes2Ao0VlJDF8Hqw90kjnESENaZvtd0IOxjoU+VzmXDeWWXi6233Zi1UJWtJ9Z/VHLVz
	7/HAQl4J5+9qlYyf1FneAju2VuJyu7oAESTeCE/91V3XSsXpn+bce899XU32Da3hbTA==
X-Received: by 2002:a50:a7a6:: with SMTP id i35mr6424540edc.96.1555777826934;
        Sat, 20 Apr 2019 09:30:26 -0700 (PDT)
X-Received: by 2002:a50:a7a6:: with SMTP id i35mr6424502edc.96.1555777826218;
        Sat, 20 Apr 2019 09:30:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555777826; cv=none;
        d=google.com; s=arc-20160816;
        b=xg7eeQTyXH37RmwcPDji0i9FOkvOTcB6YIuKkztcCDLCWefh5LWMqfqQ5OYzR3yWiZ
         Bkng3GnmVdaIfBYD8mtwXlaewFhyutUF4bviTLmjDxVt9gNkjJT68C0I/Lt94qIsQf8P
         BcPv0n8Qfw1pdANOQSu/XWczNW3Eg+T2YR3dIWtiKconYam5B5rhBgT6ge5+Duaq1sAR
         QlHaHhQ+FsaU2/eunrE5mzQQ85nWoxE1WXmzesaA6vbp+qhm57pLzCtQk/cryqPRJMTT
         bV9+2X1NIdPr7c2866UlAoxAPvgWcQNczsCw5ZE3ScWimWo9zQl88+wuuX3ePPJYg7y0
         EhsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RZD2TOJdguYske3XdmnLmIq3XfcXZwBSYG0QJWjhaWk=;
        b=dK+5nKcvNZ/i1rm/zawOMMOlUScB9yTL6T0wC79n1D8WHnyTfCriFXdC1h6tq1TJ+v
         3ynS+RXOO9rr6XHDAYTeHkoTvdUSiccfmmyaVqwupHjwbKg7HUYLA/xvv3fHHVZQY3AB
         HHuZUsBb62jKeu3AJIOmizRbcV3CKogLIAEDy/I5lrI3ZipFOkeNmhBgOdQTpn4Wo+vk
         H6WESQK1NcwNaSDvo2lKrVMRVnZQDdvWphtwEdkbdWfDICrGGOs+TdvWtBURz3YAliAQ
         bG8Y87HsRgfNYGLEm9t+4f3ssfZBxpaf/zwFEwNEvJh3cyKQhodYakBnp2U9LO5jToNY
         cAWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=M1iwu9ox;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d16sor1524431edj.5.2019.04.20.09.30.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 09:30:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=M1iwu9ox;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RZD2TOJdguYske3XdmnLmIq3XfcXZwBSYG0QJWjhaWk=;
        b=M1iwu9oxwvEKXc+QWcLRm6hRiQ5kUxXpfVx34XcRBUZhoRcClhsh0JUyIwC1Ht03If
         8a3G+pXgKZ9eavm0LjqGnf1JevmNy/hEoTi1kNvr/hT7CU/N9lh/wstJca1903j3q879
         zWvJI/IPpJUKqLRCxvH5qRHYbnBDUKQy+AlS8GyhCyUN0nTH4Fd/1S7KmPnCYG9mSn28
         2gQna42o0dUnhv0WrZf4ZmljAB7Iz/0ANS5d32EYaSbcFqdniC2v+w89Yc+/qAuk6ELQ
         gBYuclDgpS0azcJCu6eTr5cKRx2t41QOMFBfPxhgW4g9bkAA2N/pCgS01Ui1P8Lw52Gu
         bixQ==
X-Google-Smtp-Source: APXvYqyvovu6cFSV63PCP8G4i0thnTzgWZNHajiZGvrLh8glESaAwS8yzV/gVTNrN+wbgH9aZrQzqv2Ey0SevBe6Nm8=
X-Received: by 2002:a50:a4e4:: with SMTP id x33mr6290803edb.61.1555777825844;
 Sat, 20 Apr 2019 09:30:25 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
 <20190420153148.21548-3-pasha.tatashin@soleen.com> <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
In-Reply-To: <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Sat, 20 Apr 2019 12:30:14 -0400
Message-ID: <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > +
> > +       /* Walk and offline every singe memory_block of the dax region. */
> > +       lock_device_hotplug();
> > +       rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
> > +       unlock_device_hotplug();
> > +       if (rc)
> > +               return rc;
>
> This potential early return is the reason why memory hotremove is not
> reliable vs the driver-core. If this walk fails to offline the memory
> it will still be online, but the driver-core has no consideration for
> device-unbind failing. The ubind will proceed while the memory stays
> pinned.

Hi Dan,

Thank you for looking at this.  Are you saying, that if drv.remove()
returns a failure it is simply ignored, and unbind proceeds?

Pasha


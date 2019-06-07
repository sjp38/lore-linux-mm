Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17FFFC28CC3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 09:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9FBB212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 09:52:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9FBB212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7448C6B000C; Fri,  7 Jun 2019 05:52:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F5866B000E; Fri,  7 Jun 2019 05:52:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3CD6B0266; Fri,  7 Jun 2019 05:52:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34FE16B000C
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 05:52:51 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id n19so695174ota.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 02:52:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :subject:message-id:organization:mime-version
         :content-transfer-encoding;
        bh=J7I8vNvRONFgt6TD4SUSkCmxN3IiEdrWLERnhR8nnCM=;
        b=P4S1XOD7vpwfSK2eTcjQJLyFOVjCekcKPsCm2QnTMg4J6J4wAu/nzPrJ/TELs6QAjx
         S/CYaQYa30R9peKT41h5sG8Nihkaf6pDoFlQq9xWBqxdhZyex26whpgGxzsLfE6CX6Dq
         VwipwYqRiH+8ERY8GCZuDlFlvKXtBIcX4uLQvsszZ7ah81QWPFp6Xp8UuOQQ6pHe1W/F
         ZaUuLxsdrOueeEI+oLD0R14RJOgfjqPgrbvWyJ6zlSZOxP5OCqvH5KhI2/94DdVV2r1w
         EdYRDSs8vrkY4xharGbgpN/IEqJOazgCfaF3474AqQxHhDgZHn5Ek9FCyks5gN+3P5qT
         oXKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: APjAAAWSfWqxSdBANOveiWuyMTbUuvAO5dxXVUyXrHW4OHfePIIuEcIP
	9XbFavMKlOKKXVIioKaDSUeo2vFog17jXgwlDqawCgDjx1q/1UhGaP1f0XC8TvYUgm0SBuWrEN7
	SQkPHfUpkWmq1kCIgcFU8EMWS1A8bu2NbsIN+vuu6Hhtr2kef1+lHhB89ubxyqZKtYA==
X-Received: by 2002:aca:4a97:: with SMTP id x145mr3033892oia.120.1559901170735;
        Fri, 07 Jun 2019 02:52:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx0uzbAIDBkkjmc8/N9WcvXhhGhugv0p8P5KuVv1InXEvwsd/bZNDAVH9dY0dYAi0DMnLbd
X-Received: by 2002:aca:4a97:: with SMTP id x145mr3033870oia.120.1559901169793;
        Fri, 07 Jun 2019 02:52:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559901169; cv=none;
        d=google.com; s=arc-20160816;
        b=InmAjPrzmGTLCPA5TD/kyTSiZPosKd+DsEMjxLfVHxb+S2fv6Q/4IEK/3HvZ5lDUd5
         aY2OL+NiExrY9oJSp3Z4cpj90TH1yVfR4lnMB8Uh3hAEtbQgKGfW6raslSu19MUnq9Xn
         xlb8rxahWRVfDtROWU+rzcoTVKLzMYCDdPxSoavefbXOp38EgpjBeFoIy/CdYKWYv1VE
         pN1jVHxp/0fZI4jVXQ5uqF1Q2KHIiIzqenZxEX/ooP47v1YQglUHAMRQBSuGPbLh0g8R
         tduUumAWPCj9TbtHO7euv6XcrrllciPfCHOm5Oo8JQmzIf3deMNV6SjUNZVdLBTiG++Z
         WvKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:message-id
         :subject:to:from:date;
        bh=J7I8vNvRONFgt6TD4SUSkCmxN3IiEdrWLERnhR8nnCM=;
        b=ntUr9jENeGfCvq5/O85nIQ3AVCmMKPEp8QXYQ+SxGDkjW2M8SEF1/wNLGnx8fAorlq
         +ujfyvnkHKU6dOy5gCVF+2eiLQq/BbSTU7aUYES+gmj17/1kuaaGz+7bD7hXffS7g3Ts
         x1AJApVP06BEPGYAi+ISIrkne9Ad+ccJ6ZBp1LxQrZODiLQYks0EwK+LN5OeXQ8CMF4n
         rP4p7GQaZFYK7evMEj4CnXh457+g9zve3luf0O5KePgea/dL2ge82EF3FlRsWNmH9OHX
         ywWzGbdsJl8PS4SdQhtOefXdibfQVY3OQEtVVMZcWAAlmlxB1l5ulhsMhn3ulvMjviW8
         StgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id i20si920525ota.97.2019.06.07.02.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 02:52:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) client-ip=45.249.212.32;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.32 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS408-HUB.china.huawei.com (unknown [172.30.72.59])
	by Forcepoint Email with ESMTP id AC461D2F7002C7D59082;
	Fri,  7 Jun 2019 17:52:39 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS408-HUB.china.huawei.com
 (10.3.19.208) with Microsoft SMTP Server id 14.3.439.0; Fri, 7 Jun 2019
 17:52:28 +0800
Date: Fri, 7 Jun 2019 10:52:20 +0100
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: <linux-acpi@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linuxarm@huawei.com>
Subject: [RFC] NUMA Description Under ACPI 6.3 White Paper (v0.93)
Message-ID: <20190607105220.0000134e@huawei.com>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.202.226.61]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

This is a request for comment / review on a white paper, intended to
provide an example lead guide on how to describe NUMA systems in ACPI 6.3.

https://github.com/hisilicon/acpi-numa-whitepaper
https://github.com/hisilicon/acpi-numa-whitepaper/releases/download/v0.93/NUMA_Description_Under_ACPI_6.3_v0.93.pdf

It was prepared in conjunction with the Heterogeneous Memory Sub Team (HMST) of
the UEFI forum which has a mix of firmware and OS people (Linux and others). 

The original motivation for this was that we were writing some docs for a
more specific project (to appear shortly) and realized that only reason
some sections were necessary was because we couldn't find anything
bridging the gap between the ACPI specification and docs like those in
the kernel tree.  Hence this document targeting that hole which is hopefully
of more general use.

Exactly how this will be officially 'released' is yet to be resolved, but 
however that happens we will be maintaining a public source repository,
hopefully allowing this to be a living document, tracking future specs
and also being updated to account for how OS usage of the provided information
changes.

The document is under Creative Commons Attribution 4.0 International License.
It is a Sphinx document. Only output to pdf has been tested and
the build scripts are a bit of a mess.

Thanks to all those who have already given feedback on earlier drafts!
Additional thanks to the members of HMST for some very interesting discussions,
clarifying both my understanding and highlighting areas to focus on in this
guide.

I'm looking for all types of feedback including suggestions for
missing content (as a patch is ideal of course - I'm more than happy
to have some coauthors on this).

Jonathan

p.s. Please share with anyone you think may be interested!



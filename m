Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A103AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:59:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EE982075A
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 13:59:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EE982075A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECDDC8E010C; Fri, 22 Feb 2019 08:59:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7EDD8E0109; Fri, 22 Feb 2019 08:59:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D940F8E010C; Fri, 22 Feb 2019 08:59:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEE388E0109
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 08:59:38 -0500 (EST)
Received: by mail-ua1-f70.google.com with SMTP id g10so652092uan.2
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 05:59:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=HrfXKKXiTUZHq6RqizgvYdNg5kks1CArbC2sBZOnnMg=;
        b=VIu1WiLLMWw5gvbqRfB2Gs/J+JOkaauxxxIKYAqrpcLee44xHhlvfOhW1FYzIYaPlO
         PwPlkk0ltUyxiVIu5m+gFjMlxv0GbD5UZsY2Nf89dltzWbYZ7hQNd3fpB6oiOZf1c6vE
         7nJ5ulmLDdJfSEpw/y0znKiUoGRaBzlwE/8l0TTyJe/zo2F60YmD8ybFAS8w3i0NLolp
         KuEXTYp6GacgpO50UOTaJNddZ0EtIM8BUcP+IPyjT3EPo/rFzKEnVnEOpS3acdK6Pctz
         DyrnwbOajLK4pU6oVRxkCIZWuOPUWELXvAyA9kcf6xgOVrcfPRa9ZnPKRJ2T+mQoqVrd
         lw+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuYjIu3E0+QUYjqGRjw/98t8F5Yh3173T8RBq/b67r7jpZAGACKH
	VY5R0BBwZSA03ITBq9lPYiUGqHecnU0p2WgO5C2SGjIlX/ftS/umRmD/eFVT+lF/ldDURtKKGME
	vXaVK99ibZ3sWrejzIKVmIhrohJQG7pkGfjFnHj9f/puJAZwQvpvjmbGBvRhFYMP2kg==
X-Received: by 2002:a67:330f:: with SMTP id z15mr2242604vsz.9.1550843978403;
        Fri, 22 Feb 2019 05:59:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaN8nmaaWF0wuy7s4QI+jBTJq2NkQg2bL4mvK+HpQeGK4IZZbj5FLaxEvPwr0oGo9qGAZ3K
X-Received: by 2002:a67:330f:: with SMTP id z15mr2242575vsz.9.1550843977605;
        Fri, 22 Feb 2019 05:59:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550843977; cv=none;
        d=google.com; s=arc-20160816;
        b=OBbqe2j9tk6lhOLwfH5H7MZQZTzpdKPhbLR+N3W/RszeRiPcw0e09KpWaGDF8YphRM
         MF5oNnzaaITXg0Yc/t1ZGT03rT0PR5xW4FbE99+fv9oOrUvdVh+tEHfSSEi4r6AA2rJC
         JFjPNHev/CIOBcv3SvsFvT+naLgKSDZsNLQfgQ2aGXjr1XJ1s4D6XkEXiITMHDLtC9Do
         9WITcwyO4ffLF0h2QSLV0LcrhefVmsl/ZLu+5GetPMPsf5tKC947VrGSa7GGmTIR5ugR
         /ZW1ggxA8IqZayPNoyNY1ftgy7N+SyyC5TBtfPyt0MiNYmJp5sMDOkHALoVXtEZtAEpz
         ctXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=HrfXKKXiTUZHq6RqizgvYdNg5kks1CArbC2sBZOnnMg=;
        b=zlNgOtzqPi3WHM2mZVIh/DzeCLgiD06dORKPL2d6mNeXVz9Z2TEjm7/Sxb471UKfIO
         r5wrql1Fu+/Jux6jaBZWKf7rCm0fXHlM4P2Hr8IUdN22BPfoI7RyRdBcLG5hSTx45t70
         HGRZCNQ8mdL7OCinfGdWbacva6Yax0LTUKwiElvjVLUmHAoPCZAaVMNHUUGFHXamwR65
         /phuvY/Tb7U77rUonGqdixsfs07TQzEYPuhnImJenE8DjA+/cb75j7H9srCYx4k5L6QD
         W9C/todYOTRsWPSRX1F8LsBApp11clQAxfpQbEfjYz3VLSdlK5MPZnrrwN6VEqHcsjAE
         2KkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id g133si714782vsd.297.2019.02.22.05.59.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 05:59:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 14334D59F46AF89BE186;
	Fri, 22 Feb 2019 21:59:32 +0800 (CST)
Received: from localhost (10.47.85.38) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Fri, 22 Feb 2019
 21:59:26 +0800
Date: Fri, 22 Feb 2019 13:59:18 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Mike Rapoport <rppt@linux.ibm.com>
CC: <lsf-pc@lists.linux-foundation.org>, <linux-mm@kvack.org>
Subject: Re: [LSF/MM TOPIC]: mm documentation
Message-ID: <20190222135918.00000486@huawei.com>
In-Reply-To: <20190128070421.GA2470@rapoport-lnx>
References: <20190128070421.GA2470@rapoport-lnx>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.47.85.38]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000353, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jan 2019 09:04:22 +0200
Mike Rapoport <rppt@linux.ibm.com> wrote:

> Hi,
> 
> At the last Plumbers plenary there was a discussion about the
> documentation and one of the questions to the panel was "Is it better
> to have outdated documentation or no documentation at all?" And, not
> surprisingly, they've answered, "No documentation is better than
> outdated".
> 
> The mm documentation is, well, not entirely up to date. We can opt for
> dropping the outdated parts, which would generate a nice negative
> diffstat, but identifying the outdated documentation requires nearly
> as much effort as updating it, so I think that making and keeping
> the docs up to date would be a better option.
> 
> I'd like to discuss what can be done process-wise to improve the
> situation.
> 
> Some points I had in mind:
> 
> * Pay more attention to docs during review
> * Set an expectation level for docs accompanying a changeset
> * Add automation to aid spotting inconsistencies between the code and
>   the docs
> * Spend some cycles to review and update the existing docs
> * Spend some more cycles to add new documentation
> 
> I'd appreciate a discussion about how we can get to the second edition
> of "Understanding the Linux Virtual Memory Manager", what are the gaps
> (although they are too many), and what would be the best way to close
> these gaps.
> 

As a recent newbie in mm code...

Even though it is perhaps in need of a refresh the existence of that
book is still useful and a great deal better than many other areas
of the kernel.  I would love to see a new version, but can fully
appreciate the immense effort involved.

Jonathan


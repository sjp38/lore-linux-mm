Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 465CDC282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:39:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09F1E20811
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 16:39:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09F1E20811
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962B58E00D4; Wed,  6 Feb 2019 11:39:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 937128E00D1; Wed,  6 Feb 2019 11:39:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8277F8E00D4; Wed,  6 Feb 2019 11:39:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5472B8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 11:39:54 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id q16so6623967otf.5
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 08:39:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=GZJyKT2Xc6EBYR2Q4b1eBzQlyYZwbgNKsEvkGJExk2o=;
        b=BkhyjjASmkXDk67DnAKok1KuLHpJhjeRasqGMjX/TwGp3n8sHOONl0UuObA7UZgaGV
         K/fCq3wop5r1jUegwrRR6smr0NZRevIoavDycY4+R7RIi7ja3I434cjs7Fg9fiZKURqA
         c37/Pa28sYSFi2lHV+6Sr3nBozirRiPTn8seZcY2mG0Kt8wLiFjlNejCNqL7szSu1Dkj
         DQ4+EEEU1zhmsG432jLFtSsWuNuSb0WlG7Mi/jF5LxOpiJhFenxZE7xXezmNRbFk8uRZ
         xq2WKNciy6RpM3JTmi2IIsPKXbSYknt/NW2RNALGgX/GaP7zz8ElD+trxt78cj9MwqGV
         MbZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAubQKCkQV8yyQwl8xtGOozq/BebKC1xgPQk6GrbWi7LGXCR6EUOv
	V/Rg9Pt24e4ikxIBB0bUPbt9LwYaB0AUU9zPm47PQNvQWYDHWyRpIDe2B2wjeEaPuOTGGdt1n/S
	PEJAeM9APAo5pU6AVzpkYE+W8hXMMHiTc4HF8CTybQ1ioTNYVFmXbirlfmumzhFuZEw==
X-Received: by 2002:a9d:1ee2:: with SMTP id n89mr6212317otn.262.1549471193964;
        Wed, 06 Feb 2019 08:39:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYUev+wfAR+5mXcriztOLeBsixHAvUHXsYTeoYmYjBrKaGHUAa/bsnWKXzapLNo0ieNXnKv
X-Received: by 2002:a9d:1ee2:: with SMTP id n89mr6212291otn.262.1549471193352;
        Wed, 06 Feb 2019 08:39:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549471193; cv=none;
        d=google.com; s=arc-20160816;
        b=J+pk/5KaEksVvKtx2PUxjwF4/xRAR0RsmmjyqUQw19+VvlaK+OfGdPnM7OVlYbXHQa
         KEfcaSJODF0AjRGrauduREni9gyOg0Gjzn4PDffb6dFWc1iWgFOzFzg4uhci9m9U1FDk
         thBq9vs/eE/QBOxra8clIgjwmOjD8GoaMLSlUwNxAq2AlxW+4KI1KwT5tseQ9VA+W5UB
         9vO9FbiCuFlyOCxIQV1oVNDKJNWYAJeBH4MiTepl9hMdd9vTr9I1Dj/+1tni2/RpFs2H
         pteAMOnvWhc31JtKpGvcxWZ3zsJnVah4bCmeM5YxeTn+vb/RMMnSh0NEtmKb8lj49AI+
         5DEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=GZJyKT2Xc6EBYR2Q4b1eBzQlyYZwbgNKsEvkGJExk2o=;
        b=yrQcVn0dqYHbHvpkJus02BqKyoA3+GsgpIuLCrZ6SC4bNzNbLdClPj7SyO3zp3E0LT
         KGIdguLw8fbKRc2Igo65LnjWLvOOkIRIAMJ/Y/L3bHVwdjRJNTYljqcP/1Yek1w+WKEl
         ig7qzW55aMuenQ4bTP9KeH7z3N1c/4qSJVhqyiePh03XnXrWVgelHJpZCucgOOD5YoWU
         Xvmz8xqnyXtY4KrkL/nEyMj8jT6DALWB2sVrxBpzr2mWgG3ihC8DSAkF8VOcglIg29TT
         Xt3G46aTBS4Ty/4OgPpXk1DKPeypvofc/TSNCInvizWETy/sTQxNgktz5RUIKGSC2A8K
         fceg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id e75si9791235ote.150.2019.02.06.08.39.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 08:39:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS401-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 4130AF3CCF7C76F780C3;
	Thu,  7 Feb 2019 00:39:49 +0800 (CST)
Received: from localhost (10.202.226.61) by DGGEMS401-HUB.china.huawei.com
 (10.3.19.201) with Microsoft SMTP Server id 14.3.408.0; Thu, 7 Feb 2019
 00:39:43 +0800
Date: Wed, 6 Feb 2019 16:39:29 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Keith Busch <keith.busch@intel.com>
CC: <linux-kernel@vger.kernel.org>, <linux-acpi@vger.kernel.org>,
	<linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael Wysocki" <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	"Dan Williams" <dan.j.williams@intel.com>
Subject: Re: [PATCHv5 03/10] acpi/hmat: Parse and report heterogeneous
 memory
Message-ID: <20190206163929.0000394a@huawei.com>
In-Reply-To: <20190206160613.GG28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
	<20190124230724.10022-4-keith.busch@intel.com>
	<20190206122814.00000127@huawei.com>
	<20190206160613.GG28064@localhost.localdomain>
Organization: Huawei
X-Mailer: Claws Mail 3.16.0 (GTK+ 2.24.32; i686-w64-mingw32)
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


...

> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static int __init hmat_parse_address_range(union acpi_subtable_headers *header,
> > > +					   const unsigned long end)
> > > +{
> > > +	struct acpi_hmat_address_range *spa = (void *)header;
> > > +
> > > +	if (spa->header.length != sizeof(*spa)) {
> > > +		pr_debug("HMAT: Unexpected address range header length: %d\n",
> > > +			 spa->header.length);  
> > 
> > My gut feeling is that it's much more useful to make this always print rather
> > than debug.  Same with other error paths above.  Given the number of times
> > broken ACPI tables show up, it's nice to complain really loudly!
> > 
> > Perhaps others prefer to not do so though so I'll defer to subsystem norms.  
> 
> Yeah, I demoted these to debug based on earlier feedback. We should
> still be operational even with broken HMAT, so I don't want to create
> unnecessary panic if its broken, but I agree something should be
> immediately noticable if the firmware tables are incorrect. Maybe like
> what bad_srat() provides.

Agreed. Something general like that would be great. Let's people know they
should turn debug on.

Thanks,

Jonathan




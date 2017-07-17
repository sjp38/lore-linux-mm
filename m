Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 920096B0279
	for <linux-mm@kvack.org>; Mon, 17 Jul 2017 05:10:29 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id a62so12010008itd.2
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:10:29 -0700 (PDT)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id c3si17189010iof.196.2017.07.17.02.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jul 2017 02:10:28 -0700 (PDT)
Received: by mail-it0-x243.google.com with SMTP id 188so17381774itx.0
        for <linux-mm@kvack.org>; Mon, 17 Jul 2017 02:10:28 -0700 (PDT)
Message-ID: <1500282573.8256.6.camel@gmail.com>
Subject: Re: [PATCH 1/6] mm/zone-device: rename DEVICE_PUBLIC to DEVICE_HOST
From: Balbir Singh <bsingharora@gmail.com>
Date: Mon, 17 Jul 2017 19:09:33 +1000
In-Reply-To: <20170713211532.970-2-jglisse@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
	 <20170713211532.970-2-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, 2017-07-13 at 17:15 -0400, JA(C)rA'me Glisse wrote:
> Existing user of ZONE_DEVICE in its DEVICE_PUBLIC variant are not tie
> to specific device and behave more like host memory. This patch rename
> DEVICE_PUBLIC to DEVICE_HOST and free the name DEVICE_PUBLIC to be use
> for cache coherent device memory that has strong tie with the device
> on which the memory is (for instance on board GPU memory).
> 
> There is no functional change here.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> ---

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

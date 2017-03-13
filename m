Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 562F06B038A
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:57:19 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id f84so128507888ioj.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 11:57:19 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n23si12201101pfg.286.2017.03.13.11.57.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Mar 2017 11:57:18 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2DInAFV066239
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:57:17 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2955mtsceg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 14:57:17 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Mon, 13 Mar 2017 18:57:15 -0000
Date: Mon, 13 Mar 2017 19:57:10 +0100
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH 1/2] mm: add private lock to serialize memory hotplug
 operations
References: <20170309130616.51286-1-heiko.carstens@de.ibm.com>
 <3207330.x0D3JT6f2l@aspire.rjw.lan>
 <CAPcyv4g7_E1JTCGq1_gC7W2JtS2JXmWGPuiHW5CMNpjWs2DXpg@mail.gmail.com>
 <2552966.WcQWnf8t6b@aspire.rjw.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2552966.WcQWnf8t6b@aspire.rjw.lan>
Message-Id: <20170313185710.GA3422@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ben Hutchings <ben@decadent.org.uk>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Sebastian Ott <sebott@linux.vnet.ibm.com>

On Thu, Mar 09, 2017 at 11:34:44PM +0100, Rafael J. Wysocki wrote:
> > The memory described by devm_memremap_pages() is never "onlined" to
> > the core mm. We're only using arch_add_memory() to get a linear
> > mapping and page structures. The rest of memory hotplug is skipped,
> > and this ZONE_DEVICE memory is otherwise hidden from the core mm.
> 
> OK, that should be fine then.

So, does that mean that the patch is ok as it is? If so, it would be good
to get an Ack from both, you and Dan, please.

Thanks,
Heiko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

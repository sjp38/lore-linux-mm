Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0BE6B73EC
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 05:52:28 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j8so4982055plb.1
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 02:52:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f13si21222238plm.393.2018.12.05.02.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 02:52:26 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB5Amtjw070521
	for <linux-mm@kvack.org>; Wed, 5 Dec 2018 05:52:26 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p6by1c07h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Dec 2018 05:52:26 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Wed, 5 Dec 2018 10:52:23 -0000
Date: Wed, 5 Dec 2018 12:52:11 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [RFC PATCH 02/14] mm/hms: heterogenenous memory system (HMS)
 documentation
References: <20181203233509.20671-1-jglisse@redhat.com>
 <20181203233509.20671-3-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181203233509.20671-3-jglisse@redhat.com>
Message-Id: <20181205105210.GD19181@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Mon, Dec 03, 2018 at 06:34:57PM -0500, jglisse@redhat.com wrote:
> From: J�r�me Glisse <jglisse@redhat.com>
> 
> Add documentation to what is HMS and what it is for (see patch content).
> 
> Signed-off-by: J�r�me Glisse <jglisse@redhat.com>
> Cc: Rafael J. Wysocki <rafael@kernel.org>
> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Haggai Eran <haggaie@mellanox.com>
> Cc: Balbir Singh <balbirs@au1.ibm.com>
> Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Felix Kuehling <felix.kuehling@amd.com>
> Cc: Philip Yang <Philip.Yang@amd.com>
> Cc: Christian K�nig <christian.koenig@amd.com>
> Cc: Paul Blinzer <Paul.Blinzer@amd.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Jonathan Cameron <jonathan.cameron@huawei.com>
> Cc: Mark Hairgrove <mhairgrove@nvidia.com>
> Cc: Vivek Kini <vkini@nvidia.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Dave Airlie <airlied@redhat.com>
> Cc: Ben Skeggs <bskeggs@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  Documentation/vm/hms.rst | 275 ++++++++++++++++++++++++++++++++++-----
>  1 file changed, 246 insertions(+), 29 deletions(-)

This document describes userspace API and it's better to put it into
Documentation/admin-guide/mm.
The Documentation/vm is more for description of design and implementation.

I've spotted a couple of typos, but I think it doesn't make sense to nitpick
about them before  v10 or so ;-)
 
> diff --git a/Documentation/vm/hms.rst b/Documentation/vm/hms.rst
> index dbf0f71918a9..bd7c9e8e7077 100644
> --- a/Documentation/vm/hms.rst
> +++ b/Documentation/vm/hms.rst

-- 
Sincerely yours,
Mike.

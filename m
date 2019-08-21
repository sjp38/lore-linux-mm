Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82A89C41514
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:45:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44E1D214DA
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 18:45:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ACO16jaP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44E1D214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A58966B0282; Wed, 21 Aug 2019 14:45:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0A606B0289; Wed, 21 Aug 2019 14:45:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F7BE6B028A; Wed, 21 Aug 2019 14:45:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0184.hostedemail.com [216.40.44.184])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7E86B0282
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 14:45:29 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2952455F9E
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:45:29 +0000 (UTC)
X-FDA: 75847313178.02.robin81_12b695047fc10
X-HE-Tag: robin81_12b695047fc10
X-Filterd-Recvd-Size: 4838
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com [216.228.121.65])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 18:45:28 +0000 (UTC)
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d5d91470001>; Wed, 21 Aug 2019 11:45:27 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Wed, 21 Aug 2019 11:45:26 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Wed, 21 Aug 2019 11:45:26 -0700
Received: from DRHQMAIL107.nvidia.com (10.27.9.16) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 18:45:26 +0000
Received: from [10.2.161.131] (10.124.1.5) by DRHQMAIL107.nvidia.com
 (10.27.9.16) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 21 Aug
 2019 18:45:26 +0000
Subject: Re: [RFC PATCH v2 00/19] RDMA/FS DAX truncate proposal V1,000,002 ;-)
To: Dave Chinner <david@fromorbit.com>
CC: Jan Kara <jack@suse.cz>, Ira Weiny <ira.weiny@intel.com>, Andrew Morton
	<akpm@linux-foundation.org>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, "Theodore
 Ts'o" <tytso@mit.edu>, Michal Hocko <mhocko@suse.com>,
	<linux-xfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-nvdimm@lists.01.org>, <linux-ext4@vger.kernel.org>,
	<linux-mm@kvack.org>
References: <20190814101714.GA26273@quack2.suse.cz>
 <20190814180848.GB31490@iweiny-DESK2.sc.intel.com>
 <20190815130558.GF14313@quack2.suse.cz>
 <20190816190528.GB371@iweiny-DESK2.sc.intel.com>
 <20190817022603.GW6129@dread.disaster.area>
 <20190819063412.GA20455@quack2.suse.cz>
 <20190819092409.GM7777@dread.disaster.area>
 <ae64491b-85f8-eeca-14e8-2f09caf8abd2@nvidia.com>
 <20190820012021.GQ7777@dread.disaster.area>
 <84318b51-bd07-1d9b-d842-e65cac2ff484@nvidia.com>
 <20190820033608.GB1119@dread.disaster.area>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <29c89d84-d847-0221-70a7-9e5a3d472cda@nvidia.com>
Date: Wed, 21 Aug 2019 11:43:30 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190820033608.GB1119@dread.disaster.area>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 DRHQMAIL107.nvidia.com (10.27.9.16)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1566413127; bh=g14IgX27L0iEqAwtfxnkStXpyIeIQNw0GF3XHriRvWY=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ACO16jaP/ap0TKLBmx7hyuV5JFQiZfqp7UCvqna6b/2KLuheEl5ljqa2GaQK+VkX3
	 2o6LK53M+Zd6RFX+dlcv79kauSf6N5CjXssdmF1x2/a7RVLEismkCMFLaFqvH2SUr+
	 NxIqxfaZb0UzUGIbryHAFdvZGqeSBDHknpLK8nu+a7f/kIWSk4mN6Ra2Z3HRw6RP0k
	 5SQek5ORt0GZMJ7boIv3FRb8EfnUQYWbip+ljyYKi13OOsAzBUFu6FK8avyCjZDPDW
	 Pg0fChsXVcNZKL6LLP2jbIrh7qOe3OcRxKED2n15MC7KqHJbrMO6bpD0l6D1k1A4cL
	 iSjNXAQ5sfUwQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/19/19 8:36 PM, Dave Chinner wrote:
> On Mon, Aug 19, 2019 at 08:09:33PM -0700, John Hubbard wrote:
>> On 8/19/19 6:20 PM, Dave Chinner wrote:
>>> On Mon, Aug 19, 2019 at 05:05:53PM -0700, John Hubbard wrote:
>>>> On 8/19/19 2:24 AM, Dave Chinner wrote:
>>>>> On Mon, Aug 19, 2019 at 08:34:12AM +0200, Jan Kara wrote:
>>>>>> On Sat 17-08-19 12:26:03, Dave Chinner wrote:
>>>>>>> On Fri, Aug 16, 2019 at 12:05:28PM -0700, Ira Weiny wrote:
>>>>>>>> On Thu, Aug 15, 2019 at 03:05:58PM +0200, Jan Kara wrote:
>>>>>>>>> On Wed 14-08-19 11:08:49, Ira Weiny wrote:
>>>>>>>>>> On Wed, Aug 14, 2019 at 12:17:14PM +0200, Jan Kara wrote:
>>>> ...
> AFAIA, there is no struct file here - the memory that has been pinned
> is just something mapped into the application's address space.
> 
> It seems to me that the socket here is equivalent of the RDMA handle
> that that owns the hardware that pins the pages. Again, that RDMA
> handle is not aware of waht the mapping represents, hence need to
> hold a layout lease if it's a file mapping.
> 
> SO from the filesystem persepctive, there's no difference between
> XDP or RDMA - if it's a FSDAX mapping then it is DMAing directly
> into the filesystem's backing store and that will require use of
> layout leases to perform safely.
> 

OK, got it! Makes perfect sense.

thanks,
-- 
John Hubbard
NVIDIA


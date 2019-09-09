Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4249FC433EF
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 00:42:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10C532086D
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 00:42:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10C532086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D1216B0005; Sun,  8 Sep 2019 20:42:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97FE06B0006; Sun,  8 Sep 2019 20:42:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BCF36B0007; Sun,  8 Sep 2019 20:42:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0195.hostedemail.com [216.40.44.195])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7D46B0005
	for <linux-mm@kvack.org>; Sun,  8 Sep 2019 20:42:14 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0B697181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 00:42:14 +0000 (UTC)
X-FDA: 75913530588.19.sea85_6aaf4c52cfa24
X-HE-Tag: sea85_6aaf4c52cfa24
X-Filterd-Recvd-Size: 2580
Received: from mga18.intel.com (mga18.intel.com [134.134.136.126])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 00:42:12 +0000 (UTC)
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 Sep 2019 17:42:11 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,483,1559545200"; 
   d="scan'208";a="186351311"
Received: from shao2-debian.sh.intel.com (HELO [10.239.13.6]) ([10.239.13.6])
  by orsmga003.jf.intel.com with ESMTP; 08 Sep 2019 17:42:09 -0700
Subject: Re: [kbuild-all] [PATCH 3/3] mm: Allow find_get_page to be used for
 large pages
To: Matthew Wilcox <willy@infradead.org>, kbuild test robot <lkp@intel.com>
Cc: Song Liu <songliubraving@fb.com>, Johannes Weiner <jweiner@fb.com>,
 William Kucharski <william.kucharski@oracle.com>, linux-mm@kvack.org,
 kbuild-all@01.org, linux-fsdevel@vger.kernel.org,
 Kirill Shutemov <kirill@shutemov.name>
References: <20190905182348.5319-4-willy@infradead.org>
 <201909060632.Sn0F0fP6%lkp@intel.com>
 <20190905221232.GU29434@bombadil.infradead.org>
From: Rong Chen <rong.a.chen@intel.com>
Message-ID: <4b8c3a4d-5a16-6214-eb34-e7a5b36aeb71@intel.com>
Date: Mon, 9 Sep 2019 08:42:03 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190905221232.GU29434@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 9/6/19 6:12 AM, Matthew Wilcox wrote:
> On Fri, Sep 06, 2019 at 06:04:05AM +0800, kbuild test robot wrote:
>> Hi Matthew,
>>
>> Thank you for the patch! Yet something to improve:
>>
>> [auto build test ERROR on linus/master]
>> [cannot apply to v5.3-rc7 next-20190904]
>> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> It looks like you're not applying these to the -mm tree?  I thought that
> was included in -next.

Hi,

Sorry for the inconvenience, we'll look into it. and 0day-CI introduced 
'--base' option to record base tree info in format-patch.
could you kindly add it to help robot to base on the right tree? please 
see https://stackoverflow.com/a/37406982

Best Regards,
Rong Chen

>
>
> _______________________________________________
> kbuild-all mailing list
> kbuild-all@lists.01.org
> https://lists.01.org/mailman/listinfo/kbuild-all



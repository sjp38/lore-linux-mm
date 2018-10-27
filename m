Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2F96B0339
	for <linux-mm@kvack.org>; Sat, 27 Oct 2018 07:00:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s24-v6so2248862plp.12
        for <linux-mm@kvack.org>; Sat, 27 Oct 2018 04:00:08 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id d33-v6si13397305pla.404.2018.10.27.04.00.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 27 Oct 2018 04:00:07 -0700 (PDT)
Date: Sat, 27 Oct 2018 19:00:03 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/9] Allow persistent memory to be used like normal RAM
Message-ID: <20181027110003.5opfjr7q36rhumah@wfg-t540p.sh.intel.com>
References: <20181022201317.8558C1D8@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181022201317.8558C1D8@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, dan.j.williams@intel.com, dave.jiang@intel.com, zwisler@kernel.org, vishal.l.verma@intel.com, thomas.lendacky@amd.com, akpm@linux-foundation.org, mhocko@suse.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, ying.huang@intel.com

Hi Dave,

What's the base tree for this patchset? I tried 4.19, linux-next and
Dan's libnvdimm-for-next branch, but none applies cleanly.

Thanks,
Fengguang

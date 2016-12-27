Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D01F6B0038
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 11:28:48 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 17so522051538pfy.2
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 08:28:48 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i80si10827377pfj.169.2016.12.27.08.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 08:28:47 -0800 (PST)
Date: Wed, 28 Dec 2016 00:28:38 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] mm, vmscan: consider eligible zones in get_scan_count
Message-ID: <201612280000.aOluloG2%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tThc/1wpZn/ma/RB"
Content-Disposition: inline
In-Reply-To: <20161227155532.GI1308@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kbuild-all@01.org, Nils Holland <nholland@tisys.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Michal,

[auto build test ERROR on mmotm/master]
[also build test ERROR on v4.10-rc1 next-20161224]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/mm-vmscan-consider-eligible-zones-in-get_scan_count/20161228-000917
base:   git://git.cmpxchg.org/linux-mmotm.git master
config: i386-tinyconfig (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=i386 

All errors (new ones prefixed by >>):

   mm/vmscan.c: In function 'lruvec_lru_size_zone_idx':
>> mm/vmscan.c:264:10: error: implicit declaration of function 'lruvec_zone_lru_size' [-Werror=implicit-function-declaration]
      size = lruvec_zone_lru_size(lruvec, lru, zid);
             ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/lruvec_zone_lru_size +264 mm/vmscan.c

   258			struct zone *zone = &pgdat->node_zones[zid];
   259			unsigned long size;
   260	
   261			if (!managed_zone(zone))
   262				continue;
   263	
 > 264			size = lruvec_zone_lru_size(lruvec, lru, zid);
   265			lru_size -= min(size, lru_size);
   266		}
   267	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--tThc/1wpZn/ma/RB
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--tThc/1wpZn/ma/RB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

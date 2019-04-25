Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46288C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44269206BF
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:01:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44269206BF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06BF46B0005; Thu, 25 Apr 2019 17:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01CBC6B0006; Thu, 25 Apr 2019 17:01:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFF266B0008; Thu, 25 Apr 2019 17:01:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 97BB26B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:01:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y2so684275pfl.16
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:01:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SnFcpSmkz5a6x3twze3pIYCh8fD9bTaUkFtrJOVpJRE=;
        b=TZTLy05/qaI18EZ6IDwQGVA4XwzU5wp3p5AcZqFqMX6D9mpIXjt2L8n5/JgSxj411N
         YUS8z9OP8d7lMkkBp1s3svfVLaWcugS/VNyOoI2/Hc1xa+geGhjmQmgTKuFgmxisimwe
         8KLZ5VOVMZJSJ6EAQFQ326qvj6iAGjk7iD6ivpD9BSz2MqBIoyk+p74lug5zzAB8gmW3
         kUrNcyrr/WfJMvJa1w/gjMa/5JzzRjeRE+E2pFUOLqzBpcVhlG7eF9BVLFEDf9xeG7li
         HPhjXOAnjRLRWXdm2HvJr6caj/UCi5jaovO2TuwKQWwAKXHq/xi+5OlQS/P/f0SjGurI
         xBXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVrJCIud1zDsW9GRRbn4Keh36HPNe8Joxog3CETGioWu4Q4sWn1
	GzpePBLcMrfZPC3EOGMFUoLVJUblJRpulPihgTYUkLwzLF9XjcYxfMatcJjjnvqZvhvgJ4VJy8U
	0UxTWHRndsap1I2LPs7k6FSn6rBr+mOWCzV+2/mK6qhMw65GFvmlTXZGjV7cmxX5dCA==
X-Received: by 2002:a65:4689:: with SMTP id h9mr39263925pgr.295.1556226090249;
        Thu, 25 Apr 2019 14:01:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8TUZL0k8q38HogTcouT/QUZmK6EFMCVyAs5PlHaVa7IK5zaG6KoMDKiRO6bBpSx5lWA7I
X-Received: by 2002:a65:4689:: with SMTP id h9mr39263828pgr.295.1556226089380;
        Thu, 25 Apr 2019 14:01:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556226089; cv=none;
        d=google.com; s=arc-20160816;
        b=u/b87r+flCQOsWJeQC4q+mXw+JFtP02hBJKEpEL+igsfY4LM6wvJ5IankA4NMRsvDv
         ohBpd0g4xHIW46THEkCnIhAsOTh2q9fZivwgHAgWd8SSkVM2I3I+QVoHmj8GwAiJvU5A
         KGvyBUX54pIBHkbEnVyAhYG2eX0GFvvlFeUZPSH9NmzQF2xvS7jbgm7w9sogJ27VpBjd
         +VKsHweW1I33O4W0uHzF8QkDF4G1Be7/uZMtF0aSFNtVAx07TMH6o/quYI0O/O61R/Wz
         L1v2p7tv/m1cBcm1tE2g3E4kpq+6QTE//5YVMTaODNxNHupaMRmDdCfjfVcA5zA5mcPC
         fGzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SnFcpSmkz5a6x3twze3pIYCh8fD9bTaUkFtrJOVpJRE=;
        b=KN+1OuxwRNlbTBMABFO/5+frhQsvUK3Bkt7IQF+p8VOgMwHDQ99ClqKKp2FFn50VXq
         vtotX+B90AWKecG8nnSN8jWgECzsp1Px106iWGKsHEyJpfkS+vzxd0zXeYDLYemgdDde
         RKyORFMMubv8d3f7hqDnzrHmImBeS1g6XliugB7x/t0fCUEHgfv+dWqDS7XeLCicUMLh
         qDPyv6NBqx5iMlhNiA39uXrXIRAiET3LPPdanR6eEpZhDRE5jAL7owLb6p2x5N8i9vqZ
         OCxiO02pOr6e2DVCcpZi0qTxFFAnaPJ2978oBtSSCAExuK3xdkzKIq3fO2fSo1//QrGT
         raqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id l62si24152614pfc.65.2019.04.25.14.01.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:01:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Apr 2019 14:01:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,394,1549958400"; 
   d="scan'208";a="153793563"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga002.jf.intel.com with ESMTP; 25 Apr 2019 14:01:26 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hJlUj-0005Qk-DX; Fri, 26 Apr 2019 05:01:25 +0800
Date: Fri, 26 Apr 2019 05:01:19 +0800
From: kbuild test robot <lkp@intel.com>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: kbuild-all@01.org, cluster-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
	Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH v3 2/2] gfs2: Fix iomap write page reclaim deadlock
Message-ID: <201904260441.Ps3XKLKe%lkp@intel.com>
References: <20190425160913.1878-2-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190425160913.1878-2-agruenba@redhat.com>
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andreas,

I love your patch! Perhaps something to improve:

[auto build test WARNING on gfs2/for-next]
[also build test WARNING on v5.1-rc6 next-20190424]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Andreas-Gruenbacher/iomap-Add-a-page_prepare-callback/20190426-020018
base:   https://git.kernel.org/pub/scm/linux/kernel/git/gfs2/linux-gfs2.git for-next
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF='-fdiagnostic-prefix -D__CHECK_ENDIAN__'

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>


sparse warnings: (new ones prefixed by >>)

>> fs/gfs2/bmap.c:1014:29: sparse: sparse: symbol 'gfs2_iomap_page_ops' was not declared. Should it be static?

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation


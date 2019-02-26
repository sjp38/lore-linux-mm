Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE830C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 04:25:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9715E21841
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 04:25:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9715E21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D37C8E0003; Mon, 25 Feb 2019 23:25:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 25B6E8E0002; Mon, 25 Feb 2019 23:25:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FD058E0003; Mon, 25 Feb 2019 23:25:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BD5C88E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:25:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id o67so9492717pfa.20
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 20:25:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=QFdkBN4b5qtZnHeUgx9vlekD+7f8BU3M6Kgi0enyiNc=;
        b=s4WVa56e0HtoQHoaHIhaSu9vUTBo7YZjXbnfR9alcPot3dqHnrVlpUlaHenlPIUIDX
         fq6WxfIKWcavqc1rBXiVcJWyRfjn1lRFsvKiQ+SPLCDPbIrT7oyslJxUT0gp64mtj9V4
         cpQqbVvDCNhBaqq+U1cwb5zobnDylIiLn+r5X1kefpt53DjurVDtHbihsAOBUfUdfcbp
         rjO+RmLiXeMTlQ9l3MjH+S/PKDvvQlFcm+Hs4iVR7mhVT3E4miuqCJ6dE8rHPipPagug
         VGw+ejT9jY25EHQD/lZIn/4q5pM3QgSPEhBZ4moHafO2CBU4UAOgKy5Wz2C/gsQd3KPX
         Z+eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYyej4NKT9j5e7ggDOMDt1QNXVDEMKNRPK8glYQzQedXBauQN7N
	3S3uBBCj3/9z1DSX6b3QaWj8IAtDUAVSYbiGZjd82vFcZm702wd63IjJ08FShW4Tog5bN3x4CGz
	D0Dit9Sm5iK4Dj8b6wn1HXPpmZ8fuLWYqwO7ErImHSRuWs5gqHMYwCtqVHmxU4vzLNQ==
X-Received: by 2002:a17:902:583:: with SMTP id f3mr24609209plf.202.1551155121177;
        Mon, 25 Feb 2019 20:25:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZumEGM3KWTIf1/JcXufcPHCu/CXxuNWl+mSIIM118lFGurCtUeTtLoJ1VOboqstbPQmVue
X-Received: by 2002:a17:902:583:: with SMTP id f3mr24609128plf.202.1551155119621;
        Mon, 25 Feb 2019 20:25:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551155119; cv=none;
        d=google.com; s=arc-20160816;
        b=ULl80qNBkp2IvfKvOE9byALAvhjtHpmf6eihlIZUOsmgmpFBoQNcRpYtLJ/Hyisnp6
         UEkMjFYdfCRYKnphiXVRz7ugE/M3qGVP6UEhJMeYBugGV3GdksK8AyjokpSw0IaG8NOg
         AkhRkxR9Pwzqgtl6q175n0hYTeEBDF1UHuP8aCMivni1rVHKr2iPGfclPFy+0jtlcnll
         rb8KYLkUIX1iYfYT+Ta4Pixh1yIt3m74iv/m5ho1qF+7hiMeJBANFnYvyaAwzVmwdXY6
         LmZnMU0BS3Jx7KrCrZbOFXOeXLwEunnGGt2Zk00Nt8iJqzac1xuI0kAvOEW9fi1J0NsM
         xUiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=QFdkBN4b5qtZnHeUgx9vlekD+7f8BU3M6Kgi0enyiNc=;
        b=N00gXICrb44rNIpi+Fx6gUe7lphSTu95m5Jr3ej3jPjuoY2lf881SzREsBKnxzI3nO
         SNCtmfi1AKMn0t1a66jxy6xwmlkuvWVm846J0xxE7ctvVRgpegMG5exCKl9ukuR4YsQ7
         df8tYBAOBnzA68JkIPQDfpT3nwxeBbUXg4WhPteDuycfFhZaSrFmpNuSZMv8W5z/mBd1
         oqRH4dgxiQzUPZX+NnwGjrnFUENzneG8MSJQMHZ0P2gH84mqP5EqhNu0wGAk3PtKf/F3
         aH8E+5c0SzgPuPnoipPV8W3Om++35Y98L4PyU+OJGpSnfGONqidH+PvmSRLjscR/Vcp9
         k3xQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s139si5844417pgs.405.2019.02.25.20.25.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 20:25:19 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 20:25:19 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,414,1544515200"; 
   d="gz'50?scan'50,208,50";a="136297657"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by FMSMGA003.fm.intel.com with ESMTP; 25 Feb 2019 20:25:17 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gyUIv-000Dx4-0b; Tue, 26 Feb 2019 12:25:17 +0800
Date: Tue, 26 Feb 2019 12:24:17 +0800
From: kbuild test robot <lkp@intel.com>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [mmotm:master 342/391] arch/powerpc/kernel/setup_32.c:176:21: error:
 redefinition of 'alloc_stack'
Message-ID: <201902261214.GfZVc99M%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="8t9RHnE3ZwKMSgU+"
Content-Disposition: inline
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   896e6c5ee0c0ead9790f7ac202a672132bacbf66
commit: 7b6550d180d48e250049759362b5cc2cf02544c9 [342/391] powerpc: use memblock functions returning virtual address
config: powerpc-allnoconfig (attached as .config)
compiler: powerpc-linux-gnu-gcc (Debian 8.2.0-11) 8.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 7b6550d180d48e250049759362b5cc2cf02544c9
        # save the attached .config to linux build tree
        GCC_VERSION=8.2.0 make.cross ARCH=powerpc 

All errors (new ones prefixed by >>):

>> arch/powerpc/kernel/setup_32.c:176:21: error: redefinition of 'alloc_stack'
    static void *__init alloc_stack(void)
                        ^~~~~~~~~~~
   arch/powerpc/kernel/setup_32.c:165:21: note: previous definition of 'alloc_stack' was here
    static void *__init alloc_stack(void)
                        ^~~~~~~~~~~
>> arch/powerpc/kernel/setup_32.c:165:21: error: 'alloc_stack' defined but not used [-Werror=unused-function]
   cc1: all warnings being treated as errors

vim +/alloc_stack +176 arch/powerpc/kernel/setup_32.c

   164	
 > 165	static void *__init alloc_stack(void)
   166	{
   167		void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
   168	
   169		if (!ptr)
   170			panic("cannot allocate %d bytes for stack at %pS\n",
   171			      THREAD_SIZE, (void *)_RET_IP_);
   172	
   173		return ptr;
   174	}
   175	
 > 176	static void *__init alloc_stack(void)
   177	{
   178		void *ptr = memblock_alloc(THREAD_SIZE, THREAD_SIZE);
   179	
   180		if (!ptr)
   181			panic("cannot allocate %d bytes for stack at %pS\n",
   182			      THREAD_SIZE, (void *)_RET_IP_);
   183	
   184		return ptr;
   185	}
   186	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--8t9RHnE3ZwKMSgU+
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
FZgYVgMAkUE5fiFMAAA=

--8t9RHnE3ZwKMSgU+--


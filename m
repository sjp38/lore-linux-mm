Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89CA0C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 09:57:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B14A218B0
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 09:57:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B14A218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 646D26B0005; Wed, 24 Apr 2019 05:57:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F5006B0006; Wed, 24 Apr 2019 05:57:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E6566B0007; Wed, 24 Apr 2019 05:57:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0076B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:57:15 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id ba11so4005248plb.21
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 02:57:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=6bfvPg5PLuVp6ElKYctvIapInMKO8Mx+3t0rE0MTK8M=;
        b=J7lzrNbuvSo1OU4i4eroTGlifNfIrnzszPoQfl59DI8naATHbelUKlJqvcxuvfo8T7
         pJS6DcTRUkw1m8ZxdMFPX01PHpZh08PAMMQYVI4C+NVGZfAjLfNkE8CmV71blJVAa/XM
         i/l1YOVusRo8elpBZKNdTuylA86U4vWsatEPe05ClC+b22oxaIrNnlrslm1lp5KgmnA+
         CSEiOdwM4Qp7XdZw+QGrrk03WBP+WNJAVo1zrlAnRrIV8Y3C62/zo4psmTMQTc47g9l6
         2A4Rh4j8B/Tj/4Mj/Bj1GUbxFfr+WgSKPPUTjwXvmogEt00yGJnIXa9xkEnaTxYE94VP
         E/yw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVNxHQix433UqwVG9FIuIEBM1XGahuO8DB5zwlVDZ5UVVtwYkrO
	zQ5CKH0Yh4VYAe95MokOrf+gYf6ntCXTiukFL7lJrSPyJhCvy7hsnzxPmLifaNWbcLSVO8DBHWD
	oZWezdVvrZXC9v8jTzZKhWVYPQEGdZZXADrRfPt7F39yjtccDLj5EsRnFThgcyrouZg==
X-Received: by 2002:a62:424b:: with SMTP id p72mr31450400pfa.167.1556099834457;
        Wed, 24 Apr 2019 02:57:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjZEeJdgdeXtr2bhDyQilyEAGVTI6z9JpE62OBCL+t2ZdNq3uRJJGIdTglensZUgWPj7PB
X-Received: by 2002:a62:424b:: with SMTP id p72mr31450326pfa.167.1556099833223;
        Wed, 24 Apr 2019 02:57:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556099833; cv=none;
        d=google.com; s=arc-20160816;
        b=HjztOK9FHqMPQz8clnoTbeRH4QHAWIjJie7vBKrP9PhdUHEdcIA4GvWoG17nsnfwoF
         1GotNIu5EkA5xrkl5YWVfyVZyOINOrFEM9M5YdwTYZA2hyz7OLj09uTbhoomaOmSiBOC
         O5o5XFEXYMeCMdJVLj5tAnggw4l+VN5UGuyPzkkXhW93tkRccv7vp7HrJUMiuNrxGLKr
         KCcskTsDLutjbCz/umAZCVKXM9XuE5Ojy8swHiH+FOAUt4qTuXisKzkdzA0bKROdKKfj
         BvfiV9ek5ohCESGCFkT/B1n+WaScGU94K+GHX0Z+JFtJY1lN4asc6h1iI9IQ5jYAr0nd
         HwWw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=6bfvPg5PLuVp6ElKYctvIapInMKO8Mx+3t0rE0MTK8M=;
        b=EW1cHPWwqjJYloOxN00lMW8YAlFO4N+qrDLz9DGkbreicMT4PC6aSI4OL9bWKGudbC
         eUR2swiwi3r6JLkSND547+68vgQUe/6O6MebngA0UcWxrGW2r4jZXPF+ZivpR61kJkgR
         u0mXsYO1/u3fcHUyCQ1ImNsMlGHi91zFEjpSWIiJa3QavO7TrO+zsLKsMfDKV9ITchCO
         GYXfFalEeyJAXF1ApYMDtuwRr3TfqJjzBx6/wGL5sedNBpWoquEyL61HQ0JEjkgGzPHz
         ysRy05pj89tVFblJNdXFtdG7ZKcw10bC6sp/HEaiE+jbbx3Mgr438PGxF11UadO+KEmW
         jzig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id m1si17883969plt.397.2019.04.24.02.57.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 02:57:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 02:57:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,389,1549958400"; 
   d="gz'50?scan'50,208,50";a="318513837"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga005.jf.intel.com with ESMTP; 24 Apr 2019 02:57:11 -0700
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1hJEeM-0005rt-Je; Wed, 24 Apr 2019 17:57:10 +0800
Date: Wed, 24 Apr 2019 17:56:50 +0800
From: kbuild test robot <lkp@intel.com>
To: Kees Cook <keescook@chromium.org>
Cc: kbuild-all@01.org, Roman Gushchin <guro@fb.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [rgushchin:kmem_reparent.2 270/351]
 arch/arm64/include/asm/elf.h:117:3: error: implicit declaration of function
 'is_compat_task'; did you mean 'is_idle_task'?
Message-ID: <201904241747.n64pZ9Up%lkp@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="LZvS9be/3tNcYl/X"
Content-Disposition: inline
X-Patchwork-Hint: ignore
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://github.com/rgushchin/linux.git kmem_reparent.2
head:   9bcad55670928ba9722a8f9872d4db60d5bddea8
commit: 09d6592c219876dd21a11f1c3d35134ccb6937e1 [270/351] binfmt_elf: Update READ_IMPLIES_EXEC logic for modern CPUs
config: arm64-alldefconfig (attached as .config)
compiler: aarch64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 09d6592c219876dd21a11f1c3d35134ccb6937e1
        # save the attached .config to linux build tree
        GCC_VERSION=7.2.0 make.cross ARCH=arm64 

If you fix the issue, kindly add following tag
Reported-by: kbuild test robot <lkp@intel.com>
All error/warnings (new ones prefixed by >>):

   In file included from include/linux/elf.h:5:0,
                    from include/linux/module.h:15,
                    from fs/binfmt_elf.c:12:
   fs/binfmt_elf.c: In function 'load_elf_binary':
>> arch/arm64/include/asm/elf.h:117:3: error: implicit declaration of function 'is_compat_task'; did you mean 'is_idle_task'? [-Werror=implicit-function-declaration]
     (is_compat_task() && stk == EXSTACK_DEFAULT)
      ^
>> fs/binfmt_elf.c:873:6: note: in expansion of macro 'elf_read_implies_exec'
     if (elf_read_implies_exec(loc->elf_ex, executable_stack))
         ^~~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +117 arch/arm64/include/asm/elf.h

   109	
   110	/*
   111	 * 64-bit processes should not automatically gain READ_IMPLIES_EXEC. Only
   112	 * 32-bit processes without PT_GNU_STACK should trigger READ_IMPLIES_EXEC
   113	 * out of an abundance of caution against ancient toolchains not knowing
   114	 * how to mark memory protection flags correctly.
   115	 */
   116	#define elf_read_implies_exec(ex, stk)			\
 > 117		(is_compat_task() && stk == EXSTACK_DEFAULT)
   118	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--LZvS9be/3tNcYl/X
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--LZvS9be/3tNcYl/X--


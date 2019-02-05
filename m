Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 244CEC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 04:32:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A2B0E2145D
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 04:32:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2B0E2145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 382068E0074; Mon,  4 Feb 2019 23:32:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 332E48E001C; Mon,  4 Feb 2019 23:32:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1FC488E0074; Mon,  4 Feb 2019 23:32:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA76D8E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 23:32:30 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y6so1621927pfn.11
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 20:32:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=fCLNOn9KZGIHdTKgyrm2fruBpqKy5/Xup0oDS4UA3/Q=;
        b=F8Et1PIaVXi9CL/+a5DYnvkMiWwdy5R3YqIDxi3aJeSRhpe8VYVW7SqseqIEynhJcu
         sFUDK9PapO9hY4X3OnAdaTqtdcbLNpVJHxc5JSIGhYuSScNnePhHIMrLTyyBQ9tTwFQt
         kpZTmelfUD+MCT4wDZzV5831G2O6ejNlZc5FU2UCZ5YqUWxYR0Ga52nYJ9adQEXINmk8
         5NtaIBnb70MC+E30DZUE5q9w/0lZ3p94KV+GAXmH6i+9pcppEkAPBN6d1eGfJHa2NBLj
         mN6b6bkrr3ju0Y6ZKQge+GVEDaLAQK6++rKFtuOPTOrzO4QW4nkXDBAbpifri2ExWWjj
         AItw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua+I8YIdUJc/uTyDnqf9USP/luqZWDWBKOmF77HIQGMbtZV3jmB
	aFkf66ogTiWpMAU2/i+lpuS2VzHq2h8OuJa171OsNpITez8VUzoln2NLNPCc4wa1Ic9Ao+sNU1n
	gdr7qduIWzMA157To4n8vJo/Ta0t53E/Bxhjc/UGXf4CiLg72VUi431OZhGU9D/gZqw==
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr3022641pla.47.1549341150080;
        Mon, 04 Feb 2019 20:32:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9X5u4X3peXciHOTiPSON5N0H/ajF1baLxdckxKwHS8QbZhvOUUbhBNwy2YWLR7zZLfYUG
X-Received: by 2002:a17:902:1105:: with SMTP id d5mr3022566pla.47.1549341148734;
        Mon, 04 Feb 2019 20:32:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549341148; cv=none;
        d=google.com; s=arc-20160816;
        b=GY/X57e7rgDZ8A0ECU3Pt+NAEJ+xrJYzctGR3p8yH7UP3DYwZXY5uFJYVfsh6bONqi
         xWtHNzLkDMdFZsRv1cMgsyNTEooiAYFOTXymi/RaBIzMo7p+fsaiujTu6BkPthbpuWPF
         RxzsbWSyBbNonayB5ea16ObPs/EEn69mNe/W+GP2/vvfpYoTZ9GzED6z8SK3vkzLu+GJ
         WqeknBBcSSIgwxmvbM43cPZaxq7/LT3qHBCNyb8KUTPles29jWx66Ekw5aeo3Qa7xxbM
         3vkF8am7dsKE/OBy4xUH+eAEDMktrpJGiPMuqfZDijI4hhURZvfyvSAhL5j2FVIi+CNY
         geSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=fCLNOn9KZGIHdTKgyrm2fruBpqKy5/Xup0oDS4UA3/Q=;
        b=xCK0+nNfZgTXVKGNNZ7ilPDX+Zh82qfoc0TjyAvhq9bQFqU4dbylUyzcoN9llpyjwN
         q3ABHU7lHG8TjvoXk+Q57BGPrTV5sKjSlrn1Z2c3SFWEOHz+wP66AedkCKuGqN4sW3vT
         hncCYSzxb2Hobb0L88Tjhj1MRUrzU1wKj1hKBVITNjxMcIEcsPb/2XMDnHhe/6fOKwCj
         sn6pfUHPH2Sp2IZXUKIbYqS9R877scF8ApgdZglggCO9x8VUrHEncMgc+j9LQfdLT5aJ
         84BG+TfBtoYf7yMmwcBOuhGCdE+ZiLgrTWfpsJgYuamq94kpvE8qig8RvAZNphI4gB0P
         jkbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a11si2206029pla.20.2019.02.04.20.32.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 20:32:28 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 20:32:27 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,562,1539673200"; 
   d="gz'50?scan'50,208,50";a="115328086"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga008.jf.intel.com with ESMTP; 04 Feb 2019 20:32:26 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gqsPJ-0009fS-LT; Tue, 05 Feb 2019 12:32:25 +0800
Date: Tue, 5 Feb 2019 12:31:33 +0800
From: kbuild test robot <lkp@intel.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [mmotm:master 235/298] fs/binfmt_elf.c:2124:19: error: 'tmp'
 undeclared
Message-ID: <201902051227.ArSOeyy7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Content-Disposition: inline
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   3c0726114c21cd55c52c8d88f75e6ed300acd12e
commit: 58e651755138ac033c143599a659ad585ff0dbab [235/298] fs/binfmt_elf.c: use list_for_each_entry()
config: nds32-defconfig (attached as .config)
compiler: nds32le-linux-gcc (GCC) 6.4.0
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        git checkout 58e651755138ac033c143599a659ad585ff0dbab
        # save the attached .config to linux build tree
        GCC_VERSION=6.4.0 make.cross ARCH=nds32 

All errors (new ones prefixed by >>):

   fs/binfmt_elf.c: In function 'write_note_info':
>> fs/binfmt_elf.c:2124:19: error: 'tmp' undeclared (first use in this function)
      for (i = 0; i < tmp->num_notes; i++)
                      ^~~
   fs/binfmt_elf.c:2124:19: note: each undeclared identifier is reported only once for each function it appears in

vim +/tmp +2124 fs/binfmt_elf.c

3aba481f Roland McGrath  2008-01-30  2111  
3aba481f Roland McGrath  2008-01-30  2112  static int write_note_info(struct elf_note_info *info,
ecc8c772 Al Viro         2013-10-05  2113  			   struct coredump_params *cprm)
3aba481f Roland McGrath  2008-01-30  2114  {
58e65175 Alexey Dobriyan 2019-02-05  2115  	struct elf_thread_status *ets;
3aba481f Roland McGrath  2008-01-30  2116  	int i;
3aba481f Roland McGrath  2008-01-30  2117  
3aba481f Roland McGrath  2008-01-30  2118  	for (i = 0; i < info->numnote; i++)
ecc8c772 Al Viro         2013-10-05  2119  		if (!writenote(info->notes + i, cprm))
3aba481f Roland McGrath  2008-01-30  2120  			return 0;
3aba481f Roland McGrath  2008-01-30  2121  
3aba481f Roland McGrath  2008-01-30  2122  	/* write out the thread status notes section */
58e65175 Alexey Dobriyan 2019-02-05  2123  	list_for_each_entry(ets, &info->thread_list, list) {
3aba481f Roland McGrath  2008-01-30 @2124  		for (i = 0; i < tmp->num_notes; i++)
ecc8c772 Al Viro         2013-10-05  2125  			if (!writenote(&tmp->notes[i], cprm))
3aba481f Roland McGrath  2008-01-30  2126  				return 0;
3aba481f Roland McGrath  2008-01-30  2127  	}
3aba481f Roland McGrath  2008-01-30  2128  
3aba481f Roland McGrath  2008-01-30  2129  	return 1;
3aba481f Roland McGrath  2008-01-30  2130  }
3aba481f Roland McGrath  2008-01-30  2131  

:::::: The code at line 2124 was first introduced by commit
:::::: 3aba481fc94d83ff630d4b7cd2f7447010c4c6df elf core dump: notes reorg

:::::: TO: Roland McGrath <roland@redhat.com>
:::::: CC: Ingo Molnar <mingo@elte.hu>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--YiEDa0DAkWCtVeE4
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Wt9MTAH/f2tapzqQlAAA

--YiEDa0DAkWCtVeE4--


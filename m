Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DF5EC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 05:31:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B4DF20821
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 05:31:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B4DF20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF33C8E0075; Tue,  5 Feb 2019 00:31:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA3258E001C; Tue,  5 Feb 2019 00:31:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6AE18E0075; Tue,  5 Feb 2019 00:31:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 646158E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 00:31:31 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id d3so1472313pgv.23
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 21:31:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=2pJmA64Y7KYnnEs9QxDw4nK+Rf1CAGnEbGGkOXff9Lo=;
        b=rkWHKi1oJiDV19YCmHXftjOOmsAxOamCrIi4eLccEPxl5C0qZMdbYwE7ENtXJhgOMc
         x/AU7VFK6TSvqSJgCY8k8fW0NeAnRUrCmQLqef14Sb8bnPk+gWlW4AQShCL8n2QsD52K
         LRYnnxY9kh5S51KKxkoNWb4E5bu+oiO5d6nyTK+ho+9g25X90FBNOYSoKAMmbLFe8yAg
         WBjjyxGMHLnhGHhUsGvEGh8SDPTFr7G9BAVzjNFAxitP3zQ1py+RCFTHo4Yaqhdx5Gvh
         cvW6ci8nfyi6vK3NMaZiWy/ED91c1P1OLZjwu8hUnvnTaewU/1uq+6swyXgiBiekPJvP
         xXKA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZec0fxtq09+80xTSL5+LzQvpdLypAL1Q576lp6cYoUpJcBrUp+
	gCmzFfW13Y3ZBgct2GMQLQKKPEAg4LhMCdtH6qvssSESOvOrWazWe6YMn2kpC1adueoPZVdXUXy
	rfh6IzOB5l9sawZqAgBlXDpHueMb80nCotXrgZkViwLG8TIBVh1ZY4PswMnzhwR70XQ==
X-Received: by 2002:a63:2109:: with SMTP id h9mr2889587pgh.277.1549344690657;
        Mon, 04 Feb 2019 21:31:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0NHtqq3GXaRmJMfqdwVEAj7a3n3txEKh/n9+N0gxgAclb2smQUs2VKDY3tJwwKckZe/h2
X-Received: by 2002:a63:2109:: with SMTP id h9mr2889525pgh.277.1549344689560;
        Mon, 04 Feb 2019 21:31:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549344689; cv=none;
        d=google.com; s=arc-20160816;
        b=Pn9Y8qu51YV8AUx4GxzXTHQEyJVHpRZn03Qo66Rsx/QMWNA3O38RgRtxGUgnDO7zb4
         PxL4cM97DpZBeMHNbchOW0q4enh2RnbUP5fB7yXtcF3xE+wWOMWsbxZZViijsXQR3MhH
         7unNFVo4cLjo0HAxWyqNrdSMXBMypNPB+Cp2N60QnfN1wWmyKuscSa9rlQurd16qt/Nk
         HBfAGJywbium5JJQnXHGiw2F17sr9XzDf6nZJ5psvcjD193HLaHVfnAfGjMTghwWQXi5
         4J3q1pvNG/LindtN2rr8Pbh1wV24fc/adv2mF7wCvr3ZrjaM0ICdZ4ArnSJPdLTr58z/
         sz/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=2pJmA64Y7KYnnEs9QxDw4nK+Rf1CAGnEbGGkOXff9Lo=;
        b=uwdQsKBUUV50r2M6oRcOHQ6FdoFy1W6su+C9kK0JHBvxl2xy0sClzeTtMHD7EgQeer
         WOhxlPpMJAVCqa4Hl3R6CzJetanV4HqOTIw+EPYGW8rvwCnqMXQeGGMzktmvmDjbzq+7
         K1oHD8eQBADYZMIkOV5AqkGe7b4LYX2+Tb5yMf2p49Rq/VDp/U7dE2cRt5MMVp+2N0et
         egCddpb1h5VpJ0X5dnYdwwZJM4yH/x/SFvaum/lryljtOirvEEmosJgTlp0nxN3vwJ9I
         7AM6lTWnhKsXsi34GS2rUNCrp7X/wyxUwJMOu7AKigdCwHtffzu6CkxY60SRu3X+nvyT
         7siw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 102si2310020plb.176.2019.02.04.21.31.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 21:31:29 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Feb 2019 21:31:28 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,562,1539673200"; 
   d="gz'50?scan'50,208,50";a="316384086"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga006.fm.intel.com with ESMTP; 04 Feb 2019 21:31:27 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gqtKQ-0009AX-W3; Tue, 05 Feb 2019 13:31:26 +0800
Date: Tue, 5 Feb 2019 13:30:53 +0800
From: kbuild test robot <lkp@intel.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Memory Management List <linux-mm@kvack.org>
Subject: [mmotm:master 235/298] fs/binfmt_elf.c:2124:19: error: 'tmp'
 undeclared; did you mean 'tm'?
Message-ID: <201902051345.nAifiFN6%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Content-Disposition: inline
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   3c0726114c21cd55c52c8d88f75e6ed300acd12e
commit: 58e651755138ac033c143599a659ad585ff0dbab [235/298] fs/binfmt_elf.c: use list_for_each_entry()
config: um-x86_64_defconfig (attached as .config)
compiler: gcc-8 (Debian 8.2.0-14) 8.2.0
reproduce:
        git checkout 58e651755138ac033c143599a659ad585ff0dbab
        # save the attached .config to linux build tree
        make ARCH=um SUBARCH=x86_64

All errors (new ones prefixed by >>):

   fs/binfmt_elf.c: In function 'write_note_info':
>> fs/binfmt_elf.c:2124:19: error: 'tmp' undeclared (first use in this function); did you mean 'tm'?
      for (i = 0; i < tmp->num_notes; i++)
                      ^~~
                      tm
   fs/binfmt_elf.c:2124:19: note: each undeclared identifier is reported only once for each function it appears in

vim +2124 fs/binfmt_elf.c

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

--yrj/dFKFPuw6o+aM
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--yrj/dFKFPuw6o+aM--


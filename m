Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01B7AC282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:13:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E949206B6
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:13:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E949206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01F808E0005; Tue, 12 Feb 2019 19:13:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE9A38E0001; Tue, 12 Feb 2019 19:13:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D63DA8E0005; Tue, 12 Feb 2019 19:13:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 792618E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:13:35 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id t65so435239pfj.19
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:13:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hsy6cHFBiPeoRQ5aZ1LnbUJU9Yo0Vfj/R2+muGFlM98=;
        b=rF2OOT5y31R5H1HSNMLH/7PSSJvYljj9qmlzVsUtH2l189Y3o+IfEGhziYa3YImLhR
         udgQDwJ7EelgQicz5MsEjXdeFHGCRhzKt1tcOBmErJPgZ16O4KIA7937WP2NrxGlz6Tm
         JHWLItMTflgUphfP8QzrayYL5xQbwbopB0mlt/wOkQaC6qaS7gGJsaDKgD1hvR0z4awy
         qVWD/NOGnPORINyGosyackl3YLKOq6Re894MPcw3igoKO5ii0zYD7YubR5goZtNimGhS
         0Ixb4Cen+3hjDWUS6IppCn/kwfwBrb544mKv40RqXL1UST8NuzTH/GVXJYorp5tEwr7V
         evoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZVnfDQWztijoLkkL+WSJEA35te2dFnwAWRqMwKkGJXbdHdeyKO
	Mcz8CP9ccgM06VUkzGqywc5ZsXBLilqRLf0SWi1OQWCXVvt6+hzlAEXk4Zy69CJfbYPL9tCzNVu
	rb6vLLTNbgoOkQnLUg4HNGuwj8+HKWFHO+1q9jnHxcOFLE6b6yG8UJZSpOPYfkLkscg==
X-Received: by 2002:a17:902:449:: with SMTP id 67mr6763700ple.310.1550016815024;
        Tue, 12 Feb 2019 16:13:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYHVMRRAWSkY2m0nnJWoGt+J65POnLehO0QmuUDWSkjO3HhNjFCI9EapHx0hDaeTX0uDyw9
X-Received: by 2002:a17:902:449:: with SMTP id 67mr6763653ple.310.1550016814236;
        Tue, 12 Feb 2019 16:13:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550016814; cv=none;
        d=google.com; s=arc-20160816;
        b=eovNx6YYvCgRlUyXpY32XWTCfOQRCf5ypCdJjNy+yMC+Z5W0fdUoG7/BcMewcQIiin
         G/xWQSJLanUm4qXWAfW70l+js4YMi5OkSiAE9lHNaac2FK06uqInbOh2O8P3UxJWC1X9
         gWqCepTRC6Hq47rApWcFWUVzbBlAUGHRdpABbtcOj3S6ObFRMgISeVaOxoWNSTZFFeiZ
         gDEtIFC27BegjxtQRXDbvnibIpYa25kvF9cqKW29rFrm249hYDC3EbOKuRvV820ehiz9
         InzE3QhSAszO48vO0Af1k2junAF3Y31GGhT6hM+Ve4rqDMJLcwHOBtgP7l0Q+VsDwvSc
         szbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hsy6cHFBiPeoRQ5aZ1LnbUJU9Yo0Vfj/R2+muGFlM98=;
        b=kJhmfc3aBTLeFIgiD/GxopSDy57+k7mJasmyEkB4mrkoJeTpxZgVNtyOTDsFZtGS8t
         tmABCXBKHZWhCjwXJ0B3ZJTkfCTlNfjRvD4Wad6GeXdvvvvBuUiOmDJ7tyouTKKq/nUb
         LJis9kPKaaiYOs1U/uhh0Du9P0sOoV+8vUnS9+xNUqz1lWy+BIs1nIlKotH0wRxbfzMa
         /6ChlZHEDZj+9la/C3gMD+8E+Tq5BxKDToLVZ64ZmFQ6ZQ13h4n4rMrn34bEGgs37nPo
         vVUjkRoqaq2NfmtG18gMiwp3wzV1P1Tmy94/rifYAzcCZazL3h5o4sPUFZHg0ucLBFN2
         sGsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 34si6370887pgt.455.2019.02.12.16.13.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 16:13:34 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Feb 2019 16:13:33 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,364,1544515200"; 
   d="gz'50?scan'50,208,50";a="299270385"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga005.jf.intel.com with ESMTP; 12 Feb 2019 16:13:29 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gtiB7-000DFy-17; Wed, 13 Feb 2019 08:13:29 +0800
Date: Wed, 13 Feb 2019 08:12:41 +0800
From: kbuild test robot <lkp@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: kbuild-all@01.org, linux-mm@kvack.org,
	Pingfan Liu <kernelfans@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Tony Luck <tony.luck@intel.com>, linuxppc-dev@lists.ozlabs.org,
	linux-ia64@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: be more verbose about zonelist initialization
Message-ID: <201902130839.mKF7YETU%fengguang.wu@intel.com>
References: <20190212095343.23315-3-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="wRRV7LY7NUeQGEoC"
Content-Disposition: inline
In-Reply-To: <20190212095343.23315-3-mhocko@kernel.org>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Michal,

I love your patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v5.0-rc4 next-20190212]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Michal-Hocko/x86-numa-always-initialize-all-possible-nodes/20190213-071628
config: x86_64-randconfig-x016-201906 (attached as .config)
compiler: gcc-8 (Debian 8.2.0-20) 8.2.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   In file included from include/linux/gfp.h:6,
                    from include/linux/mm.h:10,
                    from mm/page_alloc.c:18:
   mm/page_alloc.c: In function 'build_zonelists':
>> mm/page_alloc.c:5423:31: error: 'z' undeclared (first use in this function)
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
                                  ^
   include/linux/mmzone.h:1036:7: note: in definition of macro 'for_each_zone_zonelist_nodemask'
     for (z = first_zones_zonelist(zlist, highidx, nodemask), zone = zonelist_zone(z); \
          ^
   mm/page_alloc.c:5423:2: note: in expansion of macro 'for_each_zone_zonelist'
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
     ^~~~~~~~~~~~~~~~~~~~~~
   mm/page_alloc.c:5423:31: note: each undeclared identifier is reported only once for each function it appears in
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
                                  ^
   include/linux/mmzone.h:1036:7: note: in definition of macro 'for_each_zone_zonelist_nodemask'
     for (z = first_zones_zonelist(zlist, highidx, nodemask), zone = zonelist_zone(z); \
          ^
   mm/page_alloc.c:5423:2: note: in expansion of macro 'for_each_zone_zonelist'
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
     ^~~~~~~~~~~~~~~~~~~~~~
>> mm/page_alloc.c:5423:25: error: 'zone' undeclared (first use in this function)
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
                            ^~~~
   include/linux/mmzone.h:1036:59: note: in definition of macro 'for_each_zone_zonelist_nodemask'
     for (z = first_zones_zonelist(zlist, highidx, nodemask), zone = zonelist_zone(z); \
                                                              ^~~~
   mm/page_alloc.c:5423:2: note: in expansion of macro 'for_each_zone_zonelist'
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
     ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/mmzone.h:1036:57: warning: left-hand operand of comma expression has no effect [-Wunused-value]
     for (z = first_zones_zonelist(zlist, highidx, nodemask), zone = zonelist_zone(z); \
                                                            ^
   include/linux/mmzone.h:1058:2: note: in expansion of macro 'for_each_zone_zonelist_nodemask'
     for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, NULL)
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   mm/page_alloc.c:5423:2: note: in expansion of macro 'for_each_zone_zonelist'
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
     ^~~~~~~~~~~~~~~~~~~~~~
   include/linux/mmzone.h:1038:50: warning: left-hand operand of comma expression has no effect [-Wunused-value]
      z = next_zones_zonelist(++z, highidx, nodemask), \
                                                     ^
   include/linux/mmzone.h:1058:2: note: in expansion of macro 'for_each_zone_zonelist_nodemask'
     for_each_zone_zonelist_nodemask(zone, z, zlist, highidx, NULL)
     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   mm/page_alloc.c:5423:2: note: in expansion of macro 'for_each_zone_zonelist'
     for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
     ^~~~~~~~~~~~~~~~~~~~~~

vim +/z +5423 mm/page_alloc.c

  5382	
  5383	/*
  5384	 * Build zonelists ordered by zone and nodes within zones.
  5385	 * This results in conserving DMA zone[s] until all Normal memory is
  5386	 * exhausted, but results in overflowing to remote node while memory
  5387	 * may still exist in local DMA zone.
  5388	 */
  5389	
  5390	static void build_zonelists(pg_data_t *pgdat)
  5391	{
  5392		static int node_order[MAX_NUMNODES];
  5393		int node, load, nr_nodes = 0;
  5394		nodemask_t used_mask;
  5395		int local_node, prev_node;
  5396	
  5397		/* NUMA-aware ordering of nodes */
  5398		local_node = pgdat->node_id;
  5399		load = nr_online_nodes;
  5400		prev_node = local_node;
  5401		nodes_clear(used_mask);
  5402	
  5403		memset(node_order, 0, sizeof(node_order));
  5404		while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
  5405			/*
  5406			 * We don't want to pressure a particular node.
  5407			 * So adding penalty to the first node in same
  5408			 * distance group to make it round-robin.
  5409			 */
  5410			if (node_distance(local_node, node) !=
  5411			    node_distance(local_node, prev_node))
  5412				node_load[node] = load;
  5413	
  5414			node_order[nr_nodes++] = node;
  5415			prev_node = node;
  5416			load--;
  5417		}
  5418	
  5419		build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
  5420		build_thisnode_zonelists(pgdat);
  5421	
  5422		pr_info("node[%d] zonelist: ", pgdat->node_id);
> 5423		for_each_zone_zonelist(zone, z, &pgdat->node_zonelists[ZONELIST_FALLBACK], MAX_NR_ZONES-1)
  5424			pr_cont("%d:%s ", zone_to_nid(zone), zone->name);
  5425		pr_cont("\n");
  5426	}
  5427	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--wRRV7LY7NUeQGEoC
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
syLim8bIDv8HAFpRoc+UAQA=

--wRRV7LY7NUeQGEoC--


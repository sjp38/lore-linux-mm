Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1272FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8751D20863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:32:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8751D20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34ECD8E0003; Tue, 26 Feb 2019 09:32:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 329008E0001; Tue, 26 Feb 2019 09:32:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A3BB8E0003; Tue, 26 Feb 2019 09:32:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC91F8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:32:13 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id f10so9886252plr.18
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:32:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mTTndO3gGqfm95Vlw6EdocWHabM6zVoxB7J1dsAfw6A=;
        b=pu88x1rT3HUPgpMPBfVxM7P2lIdMeBYnZ4466GthDAigPHOEgY1ms+CGrj6yHI9av2
         2ABwHsLVm+hWnG2PVp+fCM//BMZdt122uwSJebkgAr9HXq9Gh7RZ6EW7Me3cZKJLqEXm
         zGpkh61A3fTnpo7qJqCmLIdAYsfLSPWyfnSOJcYvprgLnymxI/0FawjhUGVyHixuIqpa
         erVrgl2tIys1XboOBEebVsc1VJ5yqHkJMwmDayxkaZrGeHX3h1fa8dTY6ww1b4plp+Hy
         hLM5X0RApOtPFYnVDh021q0KttkXFwJ8xPmuVMjVfX540+xrcmWnwDoUwBvfh+oVaNY4
         s18Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaXeWGQbXvIDStEeSEScycWBWyFFt7j6EGSUpLeGYQ6eoNmA2up
	SiW4pC5X4BfovnsXBI90m6uCkOU39rbuZGpWXJOnrvbnJgdxLkzx9qzTOdySsS2fzIypqa3ofBH
	untfS+EEmgVSZhe1ZZsiFtIzFSr5kMNq7ufAO7oiIYNja+L/qtPKNHX4CS92xtw3eqQ==
X-Received: by 2002:a17:902:e50b:: with SMTP id ck11mr26774777plb.25.1551191533207;
        Tue, 26 Feb 2019 06:32:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibcuv79zDdni2ApwVLyGPlcBTS8sJCDzRIIqEOYy6QzAGW0a1S2lFYSrtUOQ3Jvkfew68zz
X-Received: by 2002:a17:902:e50b:: with SMTP id ck11mr26774631plb.25.1551191531275;
        Tue, 26 Feb 2019 06:32:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551191531; cv=none;
        d=google.com; s=arc-20160816;
        b=Zwk6F1Ty3+GP8a+9wQit7MGnm34EdR8eq2H4D9e2/jephZUUTTktOHJWS7+9heViyr
         RTd5dt21Y14P0Omeaoz+XCl94RPwDwEqi93tRXDS/ZdKU6MNPpmQyFzpLPDOVpohTA0X
         lfMkk8k2gYzofpXhJKP0uoe/gdZzHz1kmHxGC3wit59otLN3o7soj+bKQdsKgXxgvu5c
         F2RRHR+kc1NAsIYCHJLFjTKHLV3qADTLUZqcTPgn10EngZHhlwVdTo17izmRPBEbtou6
         MPR7TlMzhrxv0LN7SsrbbqL9QwW6FtfDXImaf/p9l0b50dOshJWGic9uleA5/gcCalyb
         j38g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mTTndO3gGqfm95Vlw6EdocWHabM6zVoxB7J1dsAfw6A=;
        b=BfKLjGjx0KSf/FBjTfbIyHVQ+OfyWOdewYnqh9DVjlP5MydE0SIHiLMXAYpEBn5E6B
         F+vBGpiuvoohoj6eyhw/G8hiqE4yuQimG7WdTOzCDcTe9txXBVtvg5eQUFF/8U6tskgj
         /AucJxX5GcpVvhH0W9dqwMPhkIFz3uhgqCJEpV8Clt7Z2nT/9gCJNXFM25Pfbr7FoWtj
         dU9aV9F+EXzINkY8kvQKKflIcmB5ArAyNgPjcpmCheXLEieLaxsOG3VzIxEsuC2whYY/
         f5PlVwpeF7eOT93t/oblAX9wO/2tm1/x40A978nLoe4mP5cU9IYs62NtohSZ4oG+Olby
         30rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id z20si12952112pfl.3.2019.02.26.06.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 06:32:11 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Feb 2019 06:32:10 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,415,1544515200"; 
   d="gz'50?scan'50,208,50";a="137328516"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by orsmga002.jf.intel.com with ESMTP; 26 Feb 2019 06:32:08 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gydmB-0009fD-Ii; Tue, 26 Feb 2019 22:32:07 +0800
Date: Tue, 26 Feb 2019 22:31:38 +0800
From: kbuild test robot <lkp@intel.com>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: kbuild-all@01.org, akpm@linux-foundation.org, mhocko@suse.com,
	linux-mm@kvack.org, shaoyafang@didiglobal.com,
	Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] mm: compaction: remove unnecessary CONFIG_COMPACTION
Message-ID: <201902262213.c3OXNqfm%fengguang.wu@intel.com>
References: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Content-Disposition: inline
In-Reply-To: <1551161954-11025-1-git-send-email-laoar.shao@gmail.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yafang,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on tip/perf/core]
[also build test ERROR on v5.0-rc8 next-20190226]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Yafang-Shao/mm-compaction-remove-unnecessary-CONFIG_COMPACTION/20190226-154127
config: x86_64-randconfig-k3-02241946 (attached as .config)
compiler: gcc-8 (Debian 8.2.0-20) 8.2.0
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All error/warnings (new ones prefixed by >>):

   In file included from include/trace/define_trace.h:96,
                    from include/trace/events/compaction.h:355,
                    from mm/compaction.c:46:
   include/trace/events/compaction.h: In function 'trace_raw_output_mm_compaction_end':
   include/trace/trace_events.h:299:18: error: expected expression before ',' token
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^~~~~
   include/trace/trace_events.h:79:9: note: in expansion of macro 'PARAMS'
            PARAMS(print));         \
            ^~~~~~
   include/trace/events/compaction.h:135:1: note: in expansion of macro 'TRACE_EVENT'
    TRACE_EVENT(mm_compaction_end,
    ^~~~~~~~~~~
   include/trace/events/compaction.h:160:2: note: in expansion of macro 'TP_printk'
     TP_printk("zone_start=0x%lx migrate_pfn=0x%lx free_pfn=0x%lx zone_end=0x%lx, mode=%s status=%s",
     ^~~~~~~~~
   include/trace/events/compaction.h:166:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->status, COMPACTION_STATUS))
      ^~~~~~~~~~~~~~~~
   include/trace/events/compaction.h: In function 'trace_raw_output_mm_compaction_suitable_template':
   include/trace/trace_events.h:299:18: error: expected expression before ',' token
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^~~~~
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^~~~~~~~~
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^~~~~~~~~~~~~~~~
   include/trace/trace_events.h:299:18: warning: initialization of 'long unsigned int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^~~~~
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^~~~~~~~~
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^~~~~~~~~~~~~~~~
   include/trace/trace_events.h:299:18: note: (near initialization for 'symbols[0].mask')
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^~~~~
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^~~~~~~~~
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^~~~~~~~~~~~~~~~
   include/trace/trace_events.h:299:18: error: initializer element is not constant
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^~~~~
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^~~~~~~~~
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^~~~~~~~~~~~~~~~
   include/trace/trace_events.h:299:18: note: (near initialization for 'symbols[0].mask')
       { symbol_array, { -1, NULL }};   \
                     ^
   include/trace/trace_events.h:360:22: note: in definition of macro 'DECLARE_EVENT_CLASS'
     trace_seq_printf(s, print);     \
                         ^~~~~
   include/trace/events/compaction.h:218:2: note: in expansion of macro 'TP_printk'
     TP_printk("node=%d zone=%-8s order=%d ret=%s",
     ^~~~~~~~~
   include/trace/events/compaction.h:222:3: note: in expansion of macro '__print_symbolic'
      __print_symbolic(__entry->ret, COMPACTION_STATUS))
      ^~~~~~~~~~~~~~~~
   In file included from include/trace/define_trace.h:96,
                    from include/trace/events/compaction.h:355,
                    from mm/compaction.c:46:
   include/trace/events/compaction.h: In function 'trace_event_raw_event_mm_compaction_defer_template':
>> include/trace/events/compaction.h:262:31: error: 'struct zone' has no member named 'compact_considered'; did you mean 'compact_cached_free_pfn'?
      __entry->considered = zone->compact_considered;
                                  ^~~~~~~~~~~~~~~~~~
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:262:23: warning: assignment to 'unsigned int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
      __entry->considered = zone->compact_considered;
                          ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:263:30: error: 'struct zone' has no member named 'compact_defer_shift'
      __entry->defer_shift = zone->compact_defer_shift;
                                 ^~
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
   include/trace/events/compaction.h:263:24: warning: assignment to 'unsigned int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
      __entry->defer_shift = zone->compact_defer_shift;
                           ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:264:31: error: 'struct zone' has no member named 'compact_order_failed'
      __entry->order_failed = zone->compact_order_failed;
                                  ^~
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:264:25: warning: assignment to 'int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
      __entry->order_failed = zone->compact_order_failed;
                            ^
   include/trace/trace_events.h:720:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
   In file included from include/trace/define_trace.h:97,
                    from include/trace/events/compaction.h:355,
                    from mm/compaction.c:46:
   include/trace/events/compaction.h: In function 'perf_trace_mm_compaction_defer_template':
>> include/trace/events/compaction.h:262:31: error: 'struct zone' has no member named 'compact_considered'; did you mean 'compact_cached_free_pfn'?
      __entry->considered = zone->compact_considered;
                                  ^~~~~~~~~~~~~~~~~~
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:262:23: warning: assignment to 'unsigned int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
      __entry->considered = zone->compact_considered;
                          ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:263:30: error: 'struct zone' has no member named 'compact_defer_shift'
      __entry->defer_shift = zone->compact_defer_shift;
                                 ^~
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
   include/trace/events/compaction.h:263:24: warning: assignment to 'unsigned int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
      __entry->defer_shift = zone->compact_defer_shift;
                           ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:264:31: error: 'struct zone' has no member named 'compact_order_failed'
      __entry->order_failed = zone->compact_order_failed;
                                  ^~
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~
>> include/trace/events/compaction.h:264:25: warning: assignment to 'int' from 'const struct trace_print_flags *' makes integer from pointer without a cast [-Wint-conversion]
      __entry->order_failed = zone->compact_order_failed;
                            ^
   include/trace/perf.h:66:4: note: in definition of macro 'DECLARE_EVENT_CLASS'
     { assign; }       \
       ^~~~~~
   include/trace/events/compaction.h:258:2: note: in expansion of macro 'TP_fast_assign'
     TP_fast_assign(
     ^~~~~~~~~~~~~~

vim +262 include/trace/events/compaction.h

837d026d5 Joonsoo Kim     2015-02-11  197  
837d026d5 Joonsoo Kim     2015-02-11  198  	TP_PROTO(struct zone *zone,
837d026d5 Joonsoo Kim     2015-02-11  199  		int order,
837d026d5 Joonsoo Kim     2015-02-11  200  		int ret),
837d026d5 Joonsoo Kim     2015-02-11  201  
837d026d5 Joonsoo Kim     2015-02-11  202  	TP_ARGS(zone, order, ret),
837d026d5 Joonsoo Kim     2015-02-11  203  
837d026d5 Joonsoo Kim     2015-02-11  204  	TP_STRUCT__entry(
837d026d5 Joonsoo Kim     2015-02-11  205  		__field(int, nid)
1743d0506 Vlastimil Babka 2015-11-05  206  		__field(enum zone_type, idx)
837d026d5 Joonsoo Kim     2015-02-11  207  		__field(int, order)
837d026d5 Joonsoo Kim     2015-02-11  208  		__field(int, ret)
837d026d5 Joonsoo Kim     2015-02-11  209  	),
837d026d5 Joonsoo Kim     2015-02-11  210  
837d026d5 Joonsoo Kim     2015-02-11  211  	TP_fast_assign(
837d026d5 Joonsoo Kim     2015-02-11  212  		__entry->nid = zone_to_nid(zone);
1743d0506 Vlastimil Babka 2015-11-05  213  		__entry->idx = zone_idx(zone);
837d026d5 Joonsoo Kim     2015-02-11  214  		__entry->order = order;
837d026d5 Joonsoo Kim     2015-02-11  215  		__entry->ret = ret;
837d026d5 Joonsoo Kim     2015-02-11  216  	),
837d026d5 Joonsoo Kim     2015-02-11  217  
837d026d5 Joonsoo Kim     2015-02-11  218  	TP_printk("node=%d zone=%-8s order=%d ret=%s",
837d026d5 Joonsoo Kim     2015-02-11  219  		__entry->nid,
1743d0506 Vlastimil Babka 2015-11-05  220  		__print_symbolic(__entry->idx, ZONE_TYPE),
837d026d5 Joonsoo Kim     2015-02-11  221  		__entry->order,
fa6c7b46a Vlastimil Babka 2015-11-05 @222  		__print_symbolic(__entry->ret, COMPACTION_STATUS))
837d026d5 Joonsoo Kim     2015-02-11  223  );
837d026d5 Joonsoo Kim     2015-02-11  224  
837d026d5 Joonsoo Kim     2015-02-11  225  DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_finished,
837d026d5 Joonsoo Kim     2015-02-11  226  
837d026d5 Joonsoo Kim     2015-02-11  227  	TP_PROTO(struct zone *zone,
837d026d5 Joonsoo Kim     2015-02-11  228  		int order,
837d026d5 Joonsoo Kim     2015-02-11  229  		int ret),
837d026d5 Joonsoo Kim     2015-02-11  230  
837d026d5 Joonsoo Kim     2015-02-11  231  	TP_ARGS(zone, order, ret)
837d026d5 Joonsoo Kim     2015-02-11  232  );
837d026d5 Joonsoo Kim     2015-02-11  233  
837d026d5 Joonsoo Kim     2015-02-11  234  DEFINE_EVENT(mm_compaction_suitable_template, mm_compaction_suitable,
837d026d5 Joonsoo Kim     2015-02-11  235  
837d026d5 Joonsoo Kim     2015-02-11  236  	TP_PROTO(struct zone *zone,
837d026d5 Joonsoo Kim     2015-02-11  237  		int order,
837d026d5 Joonsoo Kim     2015-02-11  238  		int ret),
837d026d5 Joonsoo Kim     2015-02-11  239  
837d026d5 Joonsoo Kim     2015-02-11  240  	TP_ARGS(zone, order, ret)
837d026d5 Joonsoo Kim     2015-02-11  241  );
837d026d5 Joonsoo Kim     2015-02-11  242  
24e2716f6 Joonsoo Kim     2015-02-11  243  DECLARE_EVENT_CLASS(mm_compaction_defer_template,
24e2716f6 Joonsoo Kim     2015-02-11  244  
24e2716f6 Joonsoo Kim     2015-02-11  245  	TP_PROTO(struct zone *zone, int order),
24e2716f6 Joonsoo Kim     2015-02-11  246  
24e2716f6 Joonsoo Kim     2015-02-11  247  	TP_ARGS(zone, order),
24e2716f6 Joonsoo Kim     2015-02-11  248  
24e2716f6 Joonsoo Kim     2015-02-11  249  	TP_STRUCT__entry(
24e2716f6 Joonsoo Kim     2015-02-11  250  		__field(int, nid)
1743d0506 Vlastimil Babka 2015-11-05  251  		__field(enum zone_type, idx)
24e2716f6 Joonsoo Kim     2015-02-11  252  		__field(int, order)
24e2716f6 Joonsoo Kim     2015-02-11  253  		__field(unsigned int, considered)
24e2716f6 Joonsoo Kim     2015-02-11  254  		__field(unsigned int, defer_shift)
24e2716f6 Joonsoo Kim     2015-02-11  255  		__field(int, order_failed)
24e2716f6 Joonsoo Kim     2015-02-11  256  	),
24e2716f6 Joonsoo Kim     2015-02-11  257  
24e2716f6 Joonsoo Kim     2015-02-11  258  	TP_fast_assign(
24e2716f6 Joonsoo Kim     2015-02-11  259  		__entry->nid = zone_to_nid(zone);
1743d0506 Vlastimil Babka 2015-11-05  260  		__entry->idx = zone_idx(zone);
24e2716f6 Joonsoo Kim     2015-02-11  261  		__entry->order = order;
24e2716f6 Joonsoo Kim     2015-02-11 @262  		__entry->considered = zone->compact_considered;
24e2716f6 Joonsoo Kim     2015-02-11 @263  		__entry->defer_shift = zone->compact_defer_shift;
24e2716f6 Joonsoo Kim     2015-02-11 @264  		__entry->order_failed = zone->compact_order_failed;
24e2716f6 Joonsoo Kim     2015-02-11  265  	),
24e2716f6 Joonsoo Kim     2015-02-11  266  
24e2716f6 Joonsoo Kim     2015-02-11  267  	TP_printk("node=%d zone=%-8s order=%d order_failed=%d consider=%u limit=%lu",
24e2716f6 Joonsoo Kim     2015-02-11  268  		__entry->nid,
1743d0506 Vlastimil Babka 2015-11-05  269  		__print_symbolic(__entry->idx, ZONE_TYPE),
24e2716f6 Joonsoo Kim     2015-02-11  270  		__entry->order,
24e2716f6 Joonsoo Kim     2015-02-11  271  		__entry->order_failed,
24e2716f6 Joonsoo Kim     2015-02-11  272  		__entry->considered,
24e2716f6 Joonsoo Kim     2015-02-11  273  		1UL << __entry->defer_shift)
24e2716f6 Joonsoo Kim     2015-02-11  274  );
24e2716f6 Joonsoo Kim     2015-02-11  275  

:::::: The code at line 262 was first introduced by commit
:::::: 24e2716f63e613cf15d3beba3faa0711bcacc427 mm/compaction: add tracepoint to observe behaviour of compaction defer

:::::: TO: Joonsoo Kim <iamjoonsoo.kim@lge.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--vtzGhvizbBRQ85DL
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
Fu6V0mWqR5svEP8HRqvx1BHnAQA=

--vtzGhvizbBRQ85DL--


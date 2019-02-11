Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2618DC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:07:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C76302075D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 17:07:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C76302075D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 464E18E0105; Mon, 11 Feb 2019 12:07:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EAAE8E0103; Mon, 11 Feb 2019 12:07:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28F218E0105; Mon, 11 Feb 2019 12:07:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D08708E0103
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:07:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id h15so2453924pfj.22
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 09:07:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JTMBFgRu6uGMMO208jhBVwozYJbTNBfQ3MoLz2kkktQ=;
        b=NxCBZsY2/7nlXACVX7y845OGK0MxlllbokjmcTHR4jZmD554MYT0w6q6nZodvJfAC2
         xa7LtgIsM7mbRNbX/Xc17pXDnvMdegX5d/o/nbdllgasgSN6vrXI5LINhZ4EOQhg6Stn
         Z55JkGSpIw6XzFvCBKfL+0ibjz3W+sZofeZzR51/vp1rI8i5T4wEiztkV7A6/0FXCJ81
         MZ5pErvI3tbS9PFZkx3R2OM3ura2zJqjajqVmAQAuLw6kxGkgHoAjPL2JP1XLKtVfoR9
         hrrlfNjy+kkqEuICSIVhUCMIyW0LAlQvy7X248KRZ0Sr3wj6iqE3W79XSXLdFJTRI7If
         w/2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZ22RiBr2clEA8lLPjh1N0f7Z4KTQHNjl/lem2XKixu86t7l3GT
	Yh5CpJSlAhVyi7GyezlKUc9WA39NxOd8EtXyyhLqzBNsFLmFx6kdLsiwizw2TvETDbL0n6uNxrB
	dgYLt7Y/gCshsiSLGt0Hmzr3K6oG3HW8O6KbhZ29Xw6VUy3Rn9whJsAtNBvIT1pkAQw==
X-Received: by 2002:a17:902:ba85:: with SMTP id k5mr11676271pls.130.1549904875247;
        Mon, 11 Feb 2019 09:07:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZr6piwWSPdt9mZnJSYmFzpBvKGA+ZcwSc3ByEutyAC2OEAwCc9yHT8+7CPjILLkQBFMoyt
X-Received: by 2002:a17:902:ba85:: with SMTP id k5mr11676201pls.130.1549904874339;
        Mon, 11 Feb 2019 09:07:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549904874; cv=none;
        d=google.com; s=arc-20160816;
        b=XJqYlvzGX2a6V6KLFiXz27c8PgS08eKCC+e9FiimeU+sYpeFyND+YM/KWUgzrww63P
         GljAfZYsYXmFSy/otmklw5O0NavkhvL4Gaf7iFTAGuKRirYJa828zlLgzWXv7R9wtwe0
         casXqsmk9FmGFerJHIL6ILCaK7F9E9Yx+hYVe9J9h/iETKTe0Po82ZD5iSTOg0J2Y8Iz
         P7mSmIlDEzjDs5hpuWsg0WaY+a0wVs+mXT8uxDUH6sjVNetuWXwRhKwhDczkbq6gSVwk
         WRwaVagsPVkvi6Mbllfvuz7T+jQSJmv4LkcmtcgED49swbOURluvIMgsN197PfnDPEXT
         CB/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JTMBFgRu6uGMMO208jhBVwozYJbTNBfQ3MoLz2kkktQ=;
        b=DDwUdqyKdf8+2dWL93Gjwn+PnJ2HbRMDIZHT8cSF2QLMgRCu+mOklhDAQk5F38UgKx
         B/e7HPTnfaarDteVf6Ab3zaZuVoN82H/q8R8KUoEukabjqWBeEiw/pNhOa5L6AxoNLN5
         wfO84Vk3m+rkY1aCqeFY3J8vebNM552el31lCV9/o4btiKBsupRBeFlOC2Mj98eM38oh
         7pRq+svVFfg+Gt/9H81QOSAwThMlGck/fBZfjDtTcGh14LuU4Dpwwh4MJCRBCB4qY+mM
         8vbY64UQaRVIYAN3iTnTP51HTdgQOTRQNT0FStFAotXRMr4n7g2fwruhJVxSZYRxlQ4S
         V4Fg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d37si11222741plb.140.2019.02.11.09.07.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 09:07:54 -0800 (PST)
Received-SPF: pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lkp@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=lkp@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 09:07:53 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,359,1544515200"; 
   d="gz'50?scan'50,208,50";a="318086429"
Received: from lkp-server01.sh.intel.com (HELO lkp-server01) ([10.239.97.150])
  by fmsmga006.fm.intel.com with ESMTP; 11 Feb 2019 09:07:52 -0800
Received: from kbuild by lkp-server01 with local (Exim 4.89)
	(envelope-from <lkp@intel.com>)
	id 1gtF3f-000GYu-Lk; Tue, 12 Feb 2019 01:07:51 +0800
Date: Tue, 12 Feb 2019 01:07:37 +0800
From: kbuild test robot <lkp@intel.com>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: kbuild-all@01.org, linux-mm@kvack.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] mm: workingset: replace IRQ-off check with a lockdep
 assert.
Message-ID: <201902120126.o9SedEMP%fengguang.wu@intel.com>
References: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="gBBFr7Ir9EOA20Yy"
Content-Disposition: inline
In-Reply-To: <20190211095724.nmflaigqlcipbxtk@linutronix.de>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Sebastian,

Thank you for the patch! Yet something to improve:

[auto build test ERROR on linus/master]
[also build test ERROR on v5.0-rc4 next-20190211]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Sebastian-Andrzej-Siewior/mm-workingset-replace-IRQ-off-check-with-a-lockdep-assert/20190212-001418
config: openrisc-or1ksim_defconfig (attached as .config)
compiler: or1k-linux-gcc (GCC) 6.0.0 20160327 (experimental)
reproduce:
        wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=openrisc 

All errors (new ones prefixed by >>):

   mm/workingset.c: In function 'workingset_update_node':
>> mm/workingset.c:382:2: error: implicit declaration of function 'lockdep_is_held' [-Werror=implicit-function-declaration]
     lockdep_is_held(&mapping->i_pages.xa_lock);
     ^~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/lockdep_is_held +382 mm/workingset.c

   368	
   369	void workingset_update_node(struct xa_node *node)
   370	{
   371		struct address_space *mapping;
   372	
   373		/*
   374		 * Track non-empty nodes that contain only shadow entries;
   375		 * unlink those that contain pages or are being freed.
   376		 *
   377		 * Avoid acquiring the list_lru lock when the nodes are
   378		 * already where they should be. The list_empty() test is safe
   379		 * as node->private_list is protected by the i_pages lock.
   380		 */
   381		mapping = container_of(node->array, struct address_space, i_pages);
 > 382		lockdep_is_held(&mapping->i_pages.xa_lock);
   383	
   384		if (node->count && node->count == node->nr_values) {
   385			if (list_empty(&node->private_list)) {
   386				list_lru_add(&shadow_nodes, &node->private_list);
   387				__inc_lruvec_page_state(virt_to_page(node),
   388							WORKINGSET_NODES);
   389			}
   390		} else {
   391			if (!list_empty(&node->private_list)) {
   392				list_lru_del(&shadow_nodes, &node->private_list);
   393				__dec_lruvec_page_state(virt_to_page(node),
   394							WORKINGSET_NODES);
   395			}
   396		}
   397	}
   398	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--gBBFr7Ir9EOA20Yy
Content-Type: application/gzip
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--gBBFr7Ir9EOA20Yy--


Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44929C282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 02:00:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08667217F5
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 02:00:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08667217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78B058E0004; Mon, 28 Jan 2019 21:00:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 712AD8E0001; Mon, 28 Jan 2019 21:00:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DC048E0004; Mon, 28 Jan 2019 21:00:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C5538E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 21:00:51 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id d71so12868431pgc.1
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 18:00:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=PeKTcxMnZJXcL9dcx+8eWggHGYWs4wmiTTAsX0bL7D8=;
        b=S2uCAeKbxqESb5B2m1S50dff+CpwPqYkBo0EhedP0yPkj64cyUWMDGH7hyGFwoREkf
         BUzVxxgnxeKSgtTQusbSSAD9yzt1GkklDpzfDnjIsf4uSpsWKtYbC6Y9sFC4z53Ttcf0
         mmJNu1ODKH6FhyKtvyVSO17uK9ZeTeqhGGzkq0njkQrI4rAw32csJIwlNUCegeh6vRcg
         Je/hQx+anuoQ2I9+g2p+h8ZPuuhwFDMcUCmz4oRp9XKDmSXJpbeX8NEKJDEJ1FVZvuj5
         8vKZ1hehmldCqzy1rNh3ckmuJptS21e6LgLS5ME5x54ZqluB+e4tV9inUWzvm2DXNpac
         rjeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukel+Kqz0yRHVznB/JaZk+aKZfKuCGO662rDFH8Z7vhQrVb4tC+Z
	47Ts18BcDIBR33Spnsr3/M27JBdvvyx8hqpJlcGunBm9hDXltCtj8QJf7eMI77z4Dp0+3FIJNiv
	98i72KOJXdvwSSOKhgcEJ12MY5JLpxQNwEHvOsekCLCJeFo/e7VupeCx6hQbfWiXMaw==
X-Received: by 2002:a63:b94c:: with SMTP id v12mr21919624pgo.221.1548727250766;
        Mon, 28 Jan 2019 18:00:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN78MoVNCv7T30PGT6R9ScgaWuPYab3hCtnGkIZs3J8xrRArWXp17qWX3nCiTijRyLMWjQRr
X-Received: by 2002:a63:b94c:: with SMTP id v12mr21919578pgo.221.1548727249894;
        Mon, 28 Jan 2019 18:00:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548727249; cv=none;
        d=google.com; s=arc-20160816;
        b=Ya3ZXzX5kVC6wCDUka0i/HS3c2xEb5qN8MVJkJ1czjl2YAIaJEniyQSAVdTPJqBW97
         TifI7PZCpFikgv/ra4HojW3iwK1kauZch8zHZcK2QDxzkQh2gSjgMJxB4ffRAPhTdVOp
         HN8tLFE+Nc15UXaxRM7SzC5MVL8NyKF3xG4kuui6g3yFmbDghmnhUoAdQ0gBOYdzs/6+
         /NXC7teAabB/342oUi87R8eYwD7XVoqnpGF4IEnmx1rDamDZiyiNG+Pv5GJavzaA42hN
         7DUPa7E2xlal3zkzAdrRIqedM08vgRrMZKDNnGoWsyl9wxud7gONFOOwZKSo+eyvoKze
         9Gcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=PeKTcxMnZJXcL9dcx+8eWggHGYWs4wmiTTAsX0bL7D8=;
        b=TneM7297Z0+R+yX/EuZ/GSBJfq3xXiYqPRmmq18GxM4IU4N761jPs/hUp2X42hso6a
         WbNHdng4fWb1bY7Zm9WEidcT1YR9pNojab3DNfpp1+U4Bs81fd1aC/0kGSODctZU+rGJ
         k8mnVJ1taUcBy5/+WrCOV98kvEtdsQOWvMS/9JbH5RS8lNptFdDdCXaXymiz+cAMF5nd
         11NsMDoUGUUmStjfqt7q1FPeo8EyMDD8FJ2W+s6Sa8svtGbyLIGi2VxcqFkzldL613Fs
         CvCis40KAgTSIoL9GQkAaIVn3fgaCiPUnGdSxSSffUfgN6eB1PeeNEzknWAMPKs/ihIQ
         Svjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 1si1932954plo.195.2019.01.28.18.00.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 18:00:49 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Jan 2019 18:00:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,535,1539673200"; 
   d="scan'208";a="129312155"
Received: from jpeng5-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.211.249])
  by FMSMGA003.fm.intel.com with ESMTP; 28 Jan 2019 18:00:45 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1goIhg-0004lj-M2; Tue, 29 Jan 2019 10:00:44 +0800
Date: Tue, 29 Jan 2019 10:00:44 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Huang Ying <ying.huang@intel.com>,
	Zhang Yi <yi.z.zhang@linux.intel.com>, kvm@vger.kernel.org,
	Dave Hansen <dave.hansen@intel.com>,
	Liu Jingqi <jingqi.liu@intel.com>, Fan Du <fan.du@intel.com>,
	Dong Eddie <eddie.dong@intel.com>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-accelerators@lists.ozlabs.org,
	Linux Memory Management List <linux-mm@kvack.org>,
	Peng Dong <dongx.peng@intel.com>, Yao Yuan <yuan.yao@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC][PATCH v2 00/21] PMEM NUMA node and hotness
 accounting/migration
Message-ID: <20190129020044.a5h3wjjqsf4tnwbs@wfg-t540p.sh.intel.com>
References: <20181226131446.330864849@intel.com>
 <20181227203158.GO16738@dhcp22.suse.cz>
 <20181228050806.ewpxtwo3fpw7h3lq@wfg-t540p.sh.intel.com>
 <20181228084105.GQ16738@dhcp22.suse.cz>
 <20181228094208.7lgxhha34zpqu4db@wfg-t540p.sh.intel.com>
 <20181228121515.GS16738@dhcp22.suse.cz>
 <20181228133111.zromvopkfcg3m5oy@wfg-t540p.sh.intel.com>
 <20181228195224.GY16738@dhcp22.suse.cz>
 <20190102122110.00000206@huawei.com>
 <20190128174239.0000636b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190128174239.0000636b@huawei.com>
User-Agent: NeoMutt/20170609 (1.8.3)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jonathan,

Thanks for showing the gap on tracking hot accesses from devices.

On Mon, Jan 28, 2019 at 05:42:39PM +0000, Jonathan Cameron wrote:
>On Wed, 2 Jan 2019 12:21:10 +0000
>Jonathan Cameron <jonathan.cameron@huawei.com> wrote:
>
>> On Fri, 28 Dec 2018 20:52:24 +0100
>> Michal Hocko <mhocko@kernel.org> wrote:
>>
>> > [Ccing Mel and Andrea]
>> >
>
>Hi,
>
>I just wanted to highlight this section as I didn't feel we really addressed this
>in the earlier conversation.
>
>> * Hot pages may not be hot just because the host is using them a lot.  It would be
>>   very useful to have a means of adding information available from accelerators
>>   beyond simple accessed bits (dreaming ;)  One problem here is translation
>>   caches (ATCs) as they won't normally result in any updates to the page accessed
>>   bits.  The arm SMMU v3 spec for example makes it clear (though it's kind of
>>   obvious) that the ATS request is the only opportunity to update the accessed
>>   bit.  The nasty option here would be to periodically flush the ATC to force
>>   the access bit updates via repeats of the ATS request (ouch).
>>   That option only works if the iommu supports updating the accessed flag
>>   (optional on SMMU v3 for example).

If ATS based updates are supported, we may trigger it when closing the
/proc/pid/idle_pages file. We already do TLB flushes at that time. For
example,

[PATCH 15/21] ept-idle: EPT walk for virtual machine

        ept_idle_release():
          kvm_flush_remote_tlbs(kvm);

[PATCH 17/21] proc: introduce /proc/PID/idle_pages

        mm_idle_release():
          flush_tlb_mm(mm);

The flush cost is kind of "minimal necessary" in our current use
model, where user space scan+migration daemon will do such loop:

loop:
        walk page table N times:
                open,read,close /proc/PID/idle_pages
                (flushes TLB on file close)
                sleep for a short interval
        sort and migrate hot pages
        sleep for a while

>If we ignore the IOMMU hardware update issue which will simply need to be addressed
>by future hardware if these techniques become common, how do we address the
>Address Translation Cache issue without potentially causing big performance
>problems by flushing the cache just to force an accessed bit update?
>
>These devices are frequently used with PRI and Shared Virtual Addressing
>and can be accessing most of your memory without you having any visibility
>of it in the page tables (as they aren't walked if your ATC is well matched
>in size to your usecase.
>
>Classic example would be accelerated DB walkers like the the CCIX demo
>Xilinx has shown at a few conferences.   The whole point of those is that
>most of the time only your large set of database walkers is using your
>memory and they have translations cached for for a good part of what
>they are accessing.  Flushing that cache could hurt a lot.
>Pinning pages hurts for all the normal flexibility reasons.
>
>Last thing we want is to be migrating these pages that can be very hot but
>in an invisible fashion.

If there are some other way to get hotness for special device memory,
the user space daemon may be extended to cover that. Perhaps by
querying another new kernel interface.

By driving hotness accounting and migration in user space, we harvest
this kind of flexibility. In the daemon POV, /proc/PID/idle_pages
provides one common way to get "accessed" bits hence hotness, though
the daemon does not need to depend solely on it.

Thanks,
Fengguang


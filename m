Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6504C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:40:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6AE9C218DE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 06:40:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6AE9C218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE2848E0015; Tue, 12 Feb 2019 01:40:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D92BC8E0013; Tue, 12 Feb 2019 01:40:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA7C88E0015; Tue, 12 Feb 2019 01:40:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 865CE8E0013
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 01:40:53 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id l76so1593397pfg.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:40:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=WH5kq+PAShKAq/Y0ruxegZEEOCx7byyFK0fK50EoAVI=;
        b=L5CtSXM45+uArvbaV5l5rFAzvj8UBYep0bCzcpchfipYmCytQF1GehXBsC8uvlzcrF
         gWWQlyWedJNyEaROMU5Iwz9mVBFUxHYv8nyc+H49nFKPtISA90BZ3dw6ZKBRGuW22SpU
         BQx9AyYQOzLhW3aiN/PK+asWZNmGTKag/BjXMTi/ziQW/YE46FaCC0XwgUXmQE7TVFi2
         YbKjaVqSPsTsXUCs47CwTi6VeStC8x4BcHPafyGRQkF203MBlP+Oncv9Cwxs8cHpZURT
         bTAH32JJ/Uc6aecAp9DAEGm10cJkQVSUb22CWRLJDEMKLCGas0iliuWgnY3zyggzmYfz
         n3SA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYpGB/B03/K9NUTTSXJjAw/bTvyJgViYXKIF8KxUkUr8NRb7ilJ
	Rm1dtU3tZ2Bp5k85Hd5vM76+rqCDlZc9+TYOCcwV4YoT/V1PjL0ctqD+9rCR1m9nhkBDByECR3e
	ZFbwEIz6Lo4XWJb1lE2KL4t4gqupz5PPFKRHG5su2zQVy2rDkLbhlfxLTtKYYBBMkww==
X-Received: by 2002:a17:902:442:: with SMTP id 60mr2352453ple.73.1549953653213;
        Mon, 11 Feb 2019 22:40:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbEY9c1DLrGybXIUnDip3hsMRD4SJ4NxUNNawBWmVHAj9r8DXPPrlyTPABlGJvCs0SJdGwQ
X-Received: by 2002:a17:902:442:: with SMTP id 60mr2352416ple.73.1549953652430;
        Mon, 11 Feb 2019 22:40:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549953652; cv=none;
        d=google.com; s=arc-20160816;
        b=hfueTiryu7801QBgiWjFn2tnT0md7NbWbrU/QfSKGTMxa/epqPfwVhceXJOiseheLZ
         +zPuDdyu2zgC1uuYeNfIY51JJ5bvwddbV0P9t6bqyCX9igKAXqpjTGJy+/T0/7R56Y9e
         3hC/pe3/WMk2C3owYQ1VwY5Si+VbQCH/f+GULtLpBsQ2SDS97DsjCVgscYKape38VYNz
         0w8oXIaxeePZD6XAPTy9dB+gfJjdJEGEpVqb5olxNFJomilCJGIOQEKXb3hUg3xZ5qJT
         kfTZblZcBCTOkDshaTSUpKzICw7ziAaYfh0PPthD1CRBVyJp4nFn6Q+3mIY+4cMeabom
         jGuw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=WH5kq+PAShKAq/Y0ruxegZEEOCx7byyFK0fK50EoAVI=;
        b=cv0iE4kATTwDFaiqljJQ0lwil4LX/dsKs9cJc9V2m5UutI+zk7xLelT+1hfu8u71SS
         Tbd/Uwx4LNxBIf7HiIJBL+Up1vU+ZDa+Qptn9xi4VX+Khkbs9Ib9NZQ6kNBbbZTvrW5x
         GucVn4SyWWlyYDf5O/49XvscQlGsCx7LdU/evNDa0ixS9qO+rPPVXbUx7px0vWq8cChG
         LiPfSo2sB+rrfknBG4II16nqCc1YDiXO9CnSdyAgBB4ylo2ScoDtn0GCMLm6usjXHstH
         IE+nvamIJ4WNpFOpnsqkmLkU9rJcEv3SvbMrrNIGJHbXUhLUWOy/dSg8IiiUUlJKOPHf
         FzGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m6si182352pll.86.2019.02.11.22.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 22:40:52 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Feb 2019 22:40:51 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,361,1544515200"; 
   d="scan'208";a="142668988"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga002.fm.intel.com with ESMTP; 11 Feb 2019 22:40:49 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,
  <linux-kernel@vger.kernel.org>,  Hugh Dickins <hughd@google.com>,  "Paul
 E . McKenney" <paulmck@linux.vnet.ibm.com>,  Minchan Kim
 <minchan@kernel.org>,  Johannes Weiner <hannes@cmpxchg.org>,  Tim Chen
 <tim.c.chen@linux.intel.com>,  Mel Gorman <mgorman@techsingularity.net>,
  =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,  Michal Hocko
 <mhocko@suse.com>,  Andrea Arcangeli <aarcange@redhat.com>,  David
 Rientjes <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara
 <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  "Andrea Parri"
 <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap operations
References: <20190211083846.18888-1-ying.huang@intel.com>
	<20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
Date: Tue, 12 Feb 2019 14:40:48 +0800
In-Reply-To: <20190211190646.j6pdxqirc56inbbe@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Mon, 11 Feb 2019 14:06:46 -0500")
Message-ID: <87a7j1ldan.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Mon, Feb 11, 2019 at 04:38:46PM +0800, Huang, Ying wrote:
>> +struct swap_info_struct *get_swap_device(swp_entry_t entry)
>> +{
>> +	struct swap_info_struct *si;
>> +	unsigned long type, offset;
>> +
>> +	if (!entry.val)
>> +		goto out;
>
>> +	type = swp_type(entry);
>> +	si = swap_type_to_swap_info(type);
>
> These lines can be collapsed into swp_swap_info if you want.

Yes.  I can use that function to reduce another line from the patch.
Thanks!  Will do that.

>> +	if (!si)
>> +		goto bad_nofile;
>> +
>> +	preempt_disable();
>> +	if (!(si->flags & SWP_VALID))
>> +		goto unlock_out;
>
> After Hugh alluded to barriers, it seems the read of SWP_VALID could be
> reordered with the write in preempt_disable at runtime.  Without smp_mb()
> between the two, couldn't this happen, however unlikely a race it is?
>
> CPU0                                CPU1
>
> __swap_duplicate()
>     get_swap_device()
>         // sees SWP_VALID set
>                                    swapoff
>                                        p->flags &= ~SWP_VALID;
>                                        spin_unlock(&p->lock); // pair w/ smp_mb
>                                        ...
>                                        stop_machine(...)
>                                        p->swap_map = NULL;
>         preempt_disable()
>     read NULL p->swap_map

Andrea has helped to explain this.

Best Regards,
Huang, Ying


Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74343C3A5A1
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 13:09:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C8262077B
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 13:09:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pX3jc3nL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C8262077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 809E06B0008; Wed, 28 Aug 2019 09:09:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BAC56B000C; Wed, 28 Aug 2019 09:09:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A8B36B000D; Wed, 28 Aug 2019 09:09:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0047.hostedemail.com [216.40.44.47])
	by kanga.kvack.org (Postfix) with ESMTP id 43CBE6B0008
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 09:09:38 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 91F07180AD801
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:09:37 +0000 (UTC)
X-FDA: 75871868394.26.space59_70ead06a78330
X-HE-Tag: space59_70ead06a78330
X-Filterd-Recvd-Size: 8340
Received: from mail-pl1-f194.google.com (mail-pl1-f194.google.com [209.85.214.194])
	by imf12.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 13:09:35 +0000 (UTC)
Received: by mail-pl1-f194.google.com with SMTP id h3so1234284pls.7
        for <linux-mm@kvack.org>; Wed, 28 Aug 2019 06:09:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=TjgCg2+pwR4zMD2e3kUU+NibFW/NKIdsbSMpKOHJl9M=;
        b=pX3jc3nLFV/JjT2rMwFER+FXByvrbz+PH2IoD0Y+CXzu0AIDlhN3ov5VbRCeSvETrr
         MZxHlcIWgUqomR80FaRjHqROg44dev4dSHJR2wIzfsfzqm1io1qqbY9Y62xyozX6RKO6
         PSs9KTfUPZLAG+UWmTIxg9OPLzS98gV0ZwkolCiH8ZB/ju13GJCiylRSCLb5pig/G3fr
         5Ti93FoC3l4YiSNBks5UL6axkW8BLlUc4zvIjWvO9pRW2z9AYNErUI1FW/vN2rz64HYl
         mjIfMYxmUv9sFLAfrCo2zWRfQCwuw117Llov8hji6eSsbdBWf8tHiOSif9DdFjzk7f/b
         9i8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=TjgCg2+pwR4zMD2e3kUU+NibFW/NKIdsbSMpKOHJl9M=;
        b=j8LlFPTIAa5NsQeSfBC3tnYNFtEzrG4snezZJeYOAX55cyNckd5Ym4uFSWfVU3giM9
         jvxGoY78oHoK47CRqxnUhKqslv+nVBRNZYMp6QPQbL4xuLZmNecR+MdwwSZIe6zm7Ild
         0YWDO8y22pVkhb5oL/xcaMpLd60UMHa9fgpAGC86lAmzKbwvaHIcRKTTyYAxG8DfoytG
         LucYev4w2SzCUhkA6bf4XA1npWf7EHetdgO0KfzZqI4DvDgW0pW1r2ke783zx2CSMMSN
         +B3t9faDSoTETWLNh8AtobgjwVC2CSViSLO4vSbpE3danC7eNcDrT6QAJ/Wnt1G4MEwl
         rh5Q==
X-Gm-Message-State: APjAAAU9BI9mgF7DEEwPOZllO5qhMmOSLS5cGEHtX+NtZJpcozzIeftw
	g31C/+wjvx3heKK8Xh+ImKA=
X-Google-Smtp-Source: APXvYqyatxpdJ8nNaXIzPKX14ERyMkWAtQnByVDCVtS51zrkJGOra9qaHw2x4HGJOJvwTQCw8yWioQ==
X-Received: by 2002:a17:902:b605:: with SMTP id b5mr4284337pls.103.1566997774616;
        Wed, 28 Aug 2019 06:09:34 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id z25sm2758272pfa.91.2019.08.28.06.09.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Aug 2019 06:09:34 -0700 (PDT)
Date: Wed, 28 Aug 2019 18:39:22 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, akpm@linux-foundation.org,
	vbabka@suse.cz, mgorman@techsingularity.net,
	dan.j.williams@intel.com, osalvador@suse.de,
	richard.weiyang@gmail.com, hannes@cmpxchg.org,
	arunks@codeaurora.org, rppt@linux.vnet.ibm.com, jgg@ziepe.ca,
	amir73il@gmail.com, alexander.h.duyck@linux.intel.com,
	linux-mm@kvack.org, linux-kernel-mentees@lists.linuxfoundation.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/2] Add predictive memory reclamation and compaction
Message-ID: <20190828130922.GA10127@bharath12345-Inspiron-5559>
References: <20190813014012.30232-1-khalid.aziz@oracle.com>
 <20190813140553.GK17933@dhcp22.suse.cz>
 <3cb0af00-f091-2f3e-d6cc-73a5171e6eda@oracle.com>
 <20190814085831.GS17933@dhcp22.suse.cz>
 <d3895804-7340-a7ae-d611-62913303e9c5@oracle.com>
 <20190815170215.GQ9477@dhcp22.suse.cz>
 <2668ad2e-ee52-8c88-22c0-1952243af5a1@oracle.com>
 <20190821140632.GI3111@dhcp22.suse.cz>
 <20190826204420.GA16800@bharath12345-Inspiron-5559>
 <20190827061606.GN7538@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827061606.GN7538@dhcp22.suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal, Thank you for spending your time on this.
On Tue, Aug 27, 2019 at 08:16:06AM +0200, Michal Hocko wrote:
> On Tue 27-08-19 02:14:20, Bharath Vedartham wrote:
> > Hi Michal,
> > 
> > Here are some of my thoughts,
> > On Wed, Aug 21, 2019 at 04:06:32PM +0200, Michal Hocko wrote:
> > > On Thu 15-08-19 14:51:04, Khalid Aziz wrote:
> > > > Hi Michal,
> > > > 
> > > > The smarts for tuning these knobs can be implemented in userspace and
> > > > more knobs added to allow for what is missing today, but we get back to
> > > > the same issue as before. That does nothing to make kernel self-tuning
> > > > and adds possibly even more knobs to userspace. Something so fundamental
> > > > to kernel memory management as making free pages available when they are
> > > > needed really should be taken care of in the kernel itself. Moving it to
> > > > userspace just means the kernel is hobbled unless one installs and tunes
> > > > a userspace package correctly.
> > > 
> > > From my past experience the existing autotunig works mostly ok for a
> > > vast variety of workloads. A more clever tuning is possible and people
> > > are doing that already. Especially for cases when the machine is heavily
> > > overcommited. There are different ways to achieve that. Your new
> > > in-kernel auto tuning would have to be tested on a large variety of
> > > workloads to be proven and riskless. So I am quite skeptical to be
> > > honest.
> > Could you give some references to such works regarding tuning the kernel? 
> 
> Talk to Facebook guys and their usage of PSI to control the memory
> distribution and OOM situations.
Yup. Thanks for the pointer.
> > Essentially, Our idea here is to foresee potential memory exhaustion.
> > This foreseeing is done by observing the workload, observing the memory
> > usage of the workload. Based on this observations, we make a prediction
> > whether or not memory exhaustion could occur.
> 
> I understand that and I am not disputing this can be useful. All I do
> argue here is that there is unlikely a good "crystall ball" for most/all
> workloads that would justify its inclusion into the kernel and that this
> is something better done in the userspace where you can experiment and
> tune the behavior for a particular workload of your interest.
> 
> Therefore I would like to shift the discussion towards existing APIs and
> whether they are suitable for such an advance auto-tuning. I haven't
> heard any arguments about missing pieces.
I understand your concern here. Just confirming, by APIs you are
referring to sysctls, sysfs files and stuff like that right?
> > If memory exhaustion
> > occurs, we reclaim some more memory. kswapd stops reclaim when
> > hwmark is reached. hwmark is usually set to a fairly low percentage of
> > total memory, in my system for zone Normal hwmark is 13% of total pages.
> > So there is scope for reclaiming more pages to make sure system does not
> > suffer from a lack of pages. 
> 
> Yes and we have ways to control those watermarks that your monitoring
> tool can use to alter the reclaim behavior.
Just to confirm here, I am aware of one way which is to alter
min_kfree_bytes values. What other ways are there to alter watermarks
from user space? 
> [...]
> > > Therefore I would really focus on discussing whether we have sufficient
> > > APIs to tune the kernel to do the right thing when needed. That requires
> > > to identify gaps in that area. 
> > One thing that comes to my mind is based on the issue Khalid mentioned
> > earlier on how his desktop took more than 30secs to boot up because of
> > the caches using up a lot of memory.
> > Rather than allowing any unused memory to be the page cache, would it be
> > a good idea to fix a size for the caches and elastically change the size
> > based on the workload?
> 
> I do not think so. Limiting the pagecache is unlikely to help as it is
> really cheap to reclaim most of the time. In those cases when this is
> not the case (e.g. the underlying FS needs to flush and/or metadata)
> then the same would be possible in a restricted page cache situation
> and you could easily end up stalled waiting for pagecache (e.g. any
> executable/library) while there is a lot of memory.
That makes sense to me.
> I cannot comment on the Khalid's example because there were no details
> there but I would be really surprised if the primary source of stall was
> the pagecache.
Should have done more research before talking :) Sorry about that.
> -- 
> Michal Hocko
> SUSE Labs


Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EF9CC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 54CC9208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:17:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 54CC9208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE7F88E0003; Wed, 31 Jul 2019 09:17:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E98D08E0001; Wed, 31 Jul 2019 09:17:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D60308E0003; Wed, 31 Jul 2019 09:17:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A01CF8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:17:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l11so21445365pgc.14
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:17:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:organization:references:date:message-id
         :mime-version;
        bh=Na1tGyZdBo7fex2B3qM6Do0s1cPjTj6rT+S0BHHljwM=;
        b=BsLrLS9BiSEKBUcvNSWKad497cgE3dDZyKWUB4YHa1yr7RlwqSSdBlZPSteyPpkqI8
         gXhX7vXGnChRzjVbBxODr+cVAvmnjc6zcB5i2M2JexlUr+ZsQb+JPOprVJQCIYote+92
         kyRZIvxprXncxeMG3BvEmQ5vaHvbCMHp4uyJNAwGKyeUmCBilo0LOPGLmy8XVvuCk7Mx
         ejYOpXzyRniPysQI3M+ZJCk5t+IORrmEdkFAslxtDQ7Us8Lr3MXvaa7WIb2vEngW2LQU
         RBqobif13qNb4NjGIAS6GmpMjP5XJA/YI7BBNawVle6AGaSqVsSNde3Da1hmRDfLf7dV
         k32A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jani.nikula@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX7+o0nJW9UFR8FhRh3B/59XaN4vuTvCnxK4nsX8Xm6fB76g3++
	woj6pWK3cqZZwdSURPmmqq+7lJ987swKjFiuXsIdjCiIbOuijiYypIt9IWSAWyXQGfcZKnmt3Xg
	UoWld0B1TiqYkmEFJuF38mF7uwn1UguYUTXkSfbXMbtHkVQFcYPU6JCeqhZlNmEwAow==
X-Received: by 2002:a63:eb06:: with SMTP id t6mr3069778pgh.107.1564579061204;
        Wed, 31 Jul 2019 06:17:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyawxmG1ezWgknPCwslWshYiWdr/cd4bbFg7fZRMEpClqsLcubBKyS8L8LG8FSERZ/YmTFG
X-Received: by 2002:a63:eb06:: with SMTP id t6mr3069726pgh.107.1564579060434;
        Wed, 31 Jul 2019 06:17:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564579060; cv=none;
        d=google.com; s=arc-20160816;
        b=AwMQV93LlNNKMDzQl7XTGnZAJhVe6XJTlAk0zC/FisHj+4Th8kzXW46kWxgQwXJsxa
         Gb8iC64j8E+DqkVRmRE8vs38dfffNY1azeoLuqqmdg10RffqCUtjk4aFheoNpejCsydv
         4cyCgdGae2mzMlcJNyYrCuNcUNH1OvmL6WwravkpOUk8YMt2n58lelczQo/VnsGi2mMr
         V0LVB+Xh+1tM+KULvFFt/ZZrQ2rEW1xDRdjgMfRWkEEjS2l0TbmBG7cJKb4/Ll3zxGi7
         4Y//0MHqwe2NWCti4+gfb6Rzm9XKMEGtNTvGnCqvAfTNoG+5X8A4MUpfv5UZiiHsC8c7
         5zdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:organization:in-reply-to
         :subject:cc:to:from;
        bh=Na1tGyZdBo7fex2B3qM6Do0s1cPjTj6rT+S0BHHljwM=;
        b=FmgHenrlCFcQoATU47psV8PcyAsyxin7CK8wycFLCybBRXdOfusezkDWH4qOEBOJdG
         7r6zcIVGR6FVklljf22uAeR6AIwDS2rLEvh8zDAlTNCWdhx2BEu5zBwyiNV23VZluk4V
         dfKEaZEKe8V9P6aLE0u120gVpWv5JuYn5/XyrOPK/Z104ShWivv5YhHENHRRYvMLi50I
         GxEzSKNDV9a7eUxvmcCkvSUS/yN8DRhM9xJblLiB4vvnlv2UGrZFM1tqIX1wQqCKLsp2
         fD1C24x3eR+6ZkTIH6XZD0b4LiT3FA91Q6nDNJLl7p6GUzCHsn3nCwieHrRmL0hWtiPV
         i71w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jani.nikula@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v11si1579063pjn.44.2019.07.31.06.17.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:17:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jani.nikula@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jani.nikula@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=jani.nikula@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 31 Jul 2019 06:17:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,330,1559545200"; 
   d="scan'208";a="191241302"
Received: from jnikula-mobl3.fi.intel.com (HELO localhost) ([10.237.66.150])
  by fmsmga001.fm.intel.com with ESMTP; 31 Jul 2019 06:17:36 -0700
From: Jani Nikula <jani.nikula@linux.intel.com>
To: Masahiro Yamada <yamada.masahiro@socionext.com>, Randy Dunlap <rdunlap@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, mm-commits@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, mhocko@suse.cz, linux-mm@kvack.org, Mark Brown <broonie@kernel.org>, Linux-Next Mailing List <linux-next@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
In-Reply-To: <CAK7LNATF+D5TgTZijG3EPBVON5NmN+JcwmCBvnvkMFyR+3wF2A@mail.gmail.com>
Organization: Intel Finland Oy - BIC 0357606-4 - Westendinkatu 7, 02160 Espoo
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org> <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org> <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com> <CAK7LNASLfyreDPvNuL1svvHPC0woKnXO_bsNku4DMK6UNn4oHw@mail.gmail.com> <5e5353e2-bfab-5360-26b2-bf8c72ac7e70@infradead.org> <CAK7LNATF+D5TgTZijG3EPBVON5NmN+JcwmCBvnvkMFyR+3wF2A@mail.gmail.com>
Date: Wed, 31 Jul 2019 16:21:58 +0300
Message-ID: <87v9vimj9l.fsf@intel.com>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 05 Jul 2019, Masahiro Yamada <yamada.masahiro@socionext.com> wrote:
> On Fri, Jul 5, 2019 at 12:23 PM Randy Dunlap <rdunlap@infradead.org> wrote:
>>
>> On 7/4/19 8:09 PM, Masahiro Yamada wrote:
>> > On Fri, Jul 5, 2019 at 12:05 PM Masahiro Yamada
>> > <yamada.masahiro@socionext.com> wrote:
>> >>
>> >> On Fri, Jul 5, 2019 at 10:09 AM Randy Dunlap <rdunlap@infradead.org> wrote:
>> >>>
>> >>> On 7/4/19 3:01 PM, akpm@linux-foundation.org wrote:
>> >>>> The mm-of-the-moment snapshot 2019-07-04-15-01 has been uploaded to
>> >>>>
>> >>>>    http://www.ozlabs.org/~akpm/mmotm/
>> >>>>
>> >>>> mmotm-readme.txt says
>> >>>>
>> >>>> README for mm-of-the-moment:
>> >>>>
>> >>>> http://www.ozlabs.org/~akpm/mmotm/
>> >>>
>> >>> I get a lot of these but don't see/know what causes them:
>> >>>
>> >>> ../scripts/Makefile.build:42: ../drivers/gpu/drm/i915/oa/Makefile: No such file or directory
>> >>> make[6]: *** No rule to make target '../drivers/gpu/drm/i915/oa/Makefile'.  Stop.
>> >>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915/oa' failed
>> >>> make[5]: *** [drivers/gpu/drm/i915/oa] Error 2
>> >>> ../scripts/Makefile.build:498: recipe for target 'drivers/gpu/drm/i915' failed
>> >>>
>> >>
>> >> I checked next-20190704 tag.
>> >>
>> >> I see the empty file
>> >> drivers/gpu/drm/i915/oa/Makefile
>> >>
>> >> Did someone delete it?
>> >>
>> >
>> >
>> > I think "obj-y += oa/"
>> > in drivers/gpu/drm/i915/Makefile
>> > is redundant.
>>
>> Thanks.  It seems to be working after deleting that line.
>
>
> Could you check whether or not
> drivers/gpu/drm/i915/oa/Makefile exists in your source tree?
>
> Your build log says it was missing.
>
> But, commit 5ed7a0cf3394 ("drm/i915: Move OA files to separate folder")
> added it.  (It is just an empty file)
>
> I am just wondering why.

I've sent patches adding some content, and they'll make their way
upstream eventually. I am not sure why the empty file was added
originally. Perhaps as a placeholder, seemed benign enough.

BR,
Jani.


-- 
Jani Nikula, Intel Open Source Graphics Center


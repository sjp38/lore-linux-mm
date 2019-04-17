Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B41B6C282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74AB12183F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:00:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="ZBLFEadu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74AB12183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DCF86B0005; Wed, 17 Apr 2019 19:00:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03BC86B0006; Wed, 17 Apr 2019 18:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E46816B0007; Wed, 17 Apr 2019 18:59:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B22DA6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 18:59:59 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id n2so148482otk.19
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:59:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Y5Q86gAOv8MWLH9laJ1IXocaow5yfnrBeR8EoiIfWbU=;
        b=kG+56zMIpjnUj6pBnjHd7Be/QGjk5eKnuAtBF28GMBTvOSfgAsvTtVYLsOmfDi69ey
         iXbGqGFuZgH9iGK8/7VYbOvUX3mc2+xzjaOmR9EsjY+lucRNMwnkLPLWS9Km2Rfj/yYS
         +2okI1PPEqv5YOr++3+f/VVxOoRsdqjNbWOD/Bxz2ymS8n4qeczX7H9bVtnuhS04I6QH
         O73XbxQcYATB/ksE14132p9oqe4yb9F3TEy2Yjsl8rEuxmgrt6ol3awxD2X4mWyyx/OC
         03+oQuvJlas3EzuaBGbFOgj1hXOEwRMwv6trhi5BpN/605o/OHOgYNo65lJCtwl+cGmH
         TPAw==
X-Gm-Message-State: APjAAAV/FeEMBx/73+1I6ddIZCWeZv184+9u+O/VzLumKiO7jNXbM4IN
	OtUjRAau/pF4pEyJ0vpFFGs5cbfeKhI9CnbgS++ShBXzMNO3uML4FlFcTsPjbmlYAVKfS2pnJyw
	hi+LeeIpsGG3SdCObZSJuMlnjYy/cH6sHpfbZoRcDuP+PPVdwoGQlmN/tbOaN14Srtw==
X-Received: by 2002:a9d:6292:: with SMTP id x18mr54414396otk.224.1555541999360;
        Wed, 17 Apr 2019 15:59:59 -0700 (PDT)
X-Received: by 2002:a9d:6292:: with SMTP id x18mr54414368otk.224.1555541998601;
        Wed, 17 Apr 2019 15:59:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555541998; cv=none;
        d=google.com; s=arc-20160816;
        b=yPz21FEYmP7uwFq7j/ee+Q8mR7sk+hsgHORIbnNf2RA4sgLc0wz92euMua+8GHjgqW
         ciDSAen4S4rpIad9sCjHG0yPI7Ky1KBvFiYy4WalgdDM3sEcQQQZIKttmtp4FJgwjBOf
         2qxGKJL7u+nCuvoUBRgLyiDasej1JNJevygDlZyrqwDHMCBCFDs2HRyYie4YlzWirWL2
         Z73gID77SYkfvTUlHLb6wbls3yvrU7P84jS9Dp0S0jTM80TpgWOuMkPJC+3lQuxv4Mml
         1ZpKlJy7cxG9ehTDK9ujNksV4RggyuVqZYMeV+6QzLzX6/VMxh9nvCo4IRFepzcrzhJ9
         9WBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Y5Q86gAOv8MWLH9laJ1IXocaow5yfnrBeR8EoiIfWbU=;
        b=kvGSTjdUYoPSj7nXZ9RxPUFF2zZnDtXIbjb2o0XJUuQYtEFJ0MHxxEwNpktzVSBBvN
         GrhfKS58iGPqf8UghSHiYEYiTnXEHfUbaXtexMPrO6pJ9MSNm9ElVH56F/d+e8eKQ+n4
         lSNsfPRczFznOEaDL8yojjNqJ5L9iazpmw6OpQLBlxihuW0tuTCEpDe51XQF9rZuQvTR
         cGVcn+XJkwbxxgOegUDLPabaGzQvSP1FXOebGqq46N9LZAj+4stdgnk7Jb2d7NWDhc/Y
         8ya/y6DNmya6zcCkO+WG32i9wTjvz+ouXHUlyj2yKvRIqrhDoDB1nITDQC44icBt7iRg
         DJ5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZBLFEadu;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l4sor39823otc.127.2019.04.17.15.59.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Apr 2019 15:59:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=ZBLFEadu;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Y5Q86gAOv8MWLH9laJ1IXocaow5yfnrBeR8EoiIfWbU=;
        b=ZBLFEadujMfdBVNXmJrbI4zR196fsIe5mO0VxN2DENpJoVBadqYu0gk0x8BFoQgGPq
         OK03oOc+QwJXFHRhGDlI7HCGUn2FEDGxayOCXFrte0xS6Eixyn+gIt/g4OryYh6KKycR
         AtX1Bh19zGnaHnWO2gBlfJUTikry4l1+4Qk11EAhA94VzavMVUGVX203v5zHLieBR6zh
         iTobtE2slojYN1Tb2AHac5rvm5VvsUU57qEovxYyIrZFhvH/Prks6Ak+9axoPXJErs1g
         9Loy/hrOeN5wKsxb70LZ4bKOMK6ISrFa8Gw6DMu0Aw8V6ImUhRDqecnSs5U2wRmEqV76
         IzUw==
X-Google-Smtp-Source: APXvYqx0PiTtBkyrLfmk/jOmFbuQMwTA591NJRQvMCXkPXCoY+luPtiOJZPaujG8DsNnN9FucBhbxzpzdgGKAJXtWxA=
X-Received: by 2002:a9d:27e3:: with SMTP id c90mr57351203otb.214.1555541997937;
 Wed, 17 Apr 2019 15:59:57 -0700 (PDT)
MIME-Version: 1.0
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
In-Reply-To: <20190417150331.90219ca42a1c0db8632d0fd5@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 17 Apr 2019 15:59:46 -0700
Message-ID: <CAPcyv4hB47NJrVi1sm+7msL+6dJNhBD10BJbtLPZRcK2JK6+pg@mail.gmail.com>
Subject: Re: [PATCH v6 00/12] mm: Sub-section memory hotplug support
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Hildenbrand <david@redhat.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>, Jeff Moyer <jmoyer@redhat.com>, 
	Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, osalvador@suse.de
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 3:04 PM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Wed, 17 Apr 2019 11:38:55 -0700 Dan Williams <dan.j.williams@intel.com> wrote:
>
> > The memory hotplug section is an arbitrary / convenient unit for memory
> > hotplug. 'Section-size' units have bled into the user interface
> > ('memblock' sysfs) and can not be changed without breaking existing
> > userspace. The section-size constraint, while mostly benign for typical
> > memory hotplug, has and continues to wreak havoc with 'device-memory'
> > use cases, persistent memory (pmem) in particular. Recall that pmem uses
> > devm_memremap_pages(), and subsequently arch_add_memory(), to allocate a
> > 'struct page' memmap for pmem. However, it does not use the 'bottom
> > half' of memory hotplug, i.e. never marks pmem pages online and never
> > exposes the userspace memblock interface for pmem. This leaves an
> > opening to redress the section-size constraint.
>
> v6 and we're not showing any review activity.  Who would be suitable
> people to help out here?

There was quite a bit of review of the cover letter from Michal and
David, but you're right the details not so much as of yet. I'd like to
call out other people where I can reciprocate with some review of my
own. Oscar's altmap work looks like a good candidate for that.


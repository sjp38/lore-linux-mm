Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A32FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C30C9217F9
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:20:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C30C9217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65EB28E00D8; Wed,  6 Feb 2019 12:20:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 60CF68E00D1; Wed,  6 Feb 2019 12:20:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FD108E00D8; Wed,  6 Feb 2019 12:20:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 093A88E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:20:15 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id d18so5728361pfe.0
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:20:15 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4Y0Ol9cUuCeTtR/iHjcDPt3ULycXGBufi5ZEeL6CPm8=;
        b=efj3rZDWNcz/g5YihNLNdN2SUzwL4vKxSjwibtftBDp6r1qzjWSClhiXxvYrve4krh
         KXxEZWbieCHW8FNemenaaVdReVNVXatM7wE5VfRFdqXAm0uSxR0bZHDjItWuZxQ8EpEy
         aZoNBzLC6KuP/Zb9djF+D+9bWpH1o3Ydyh03MmkMh4fegh3gV++SlgAPu2pMlYKp9Xtd
         Q9APtyBW/CJUJcT1770omdqk6piW+8i52zQtLQCOzmOR+4AghBS1528awOB10aLyJndt
         3tkg3JhjUmcNw6Miv8vH6A9EG6BjRrPfXkrAhBGKRyW9lxzRwpbLzZJ53i5jr9lU9Q++
         5gUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubmU70gw7YL9bAHoqpuq2TfQ5nX0ijnfAri4YfhyCfJjuy6MFbO
	WXxlyCv4rQ+GpTh5r+1mJc8KIDIB58MidkWCx03pwGGVAnYIsZkoptHQH81ANNyLWahSzi+dpxA
	eu9Oaf2o5BrlripRvPeYHetdhj5paf9TOB5uAnfHYtC6syuwTcmfeZ3K03fq5CAw7DQ==
X-Received: by 2002:a63:2c0e:: with SMTP id s14mr10750814pgs.132.1549473614587;
        Wed, 06 Feb 2019 09:20:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3IagcOjEjyk2nRFpjFo6/9hy3KfDWQlCBMYLCRHuVSL8dZDHygoVv/xjWBmhMctYCJVq+KRT
X-Received: by 2002:a63:2c0e:: with SMTP id s14mr10750735pgs.132.1549473613760;
        Wed, 06 Feb 2019 09:20:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549473613; cv=none;
        d=google.com; s=arc-20160816;
        b=CZ0BsDNRwyoIJBZe/ixzMFYIC2gG+wZ0ABLg50AqOpwMWOgvAAv/QYalBltzZGjub1
         qjwgwL1ZQYyWY1abb09Bn3QD17IWdAwGzHM276GbDZ6eWn4ilJEKbJ2LvmW06UfrkI2O
         PkcGosqy4lS7DJnjnvwaESXWpHM6AgaLNpvzXk3dqgauLofDGg+ukxE2ue8u8X4gYtQE
         lXF/xzwX3SiuV0RO18E8HXw91qsFY3JqRqyeEfWp5F6LklfW1F11dZiGK+1GKSvJyNat
         9ttkgQHcPeobwsWpgmGyAnzUwqG0qljRI7bnw82roSR6gES/X25pZPeDnd7H+ud0CsSh
         9HUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4Y0Ol9cUuCeTtR/iHjcDPt3ULycXGBufi5ZEeL6CPm8=;
        b=Ic16lUTPtu5EcA70UGANFtPPbZrX94OvfTZcES18vfb+Va5lGFnYNJbnQfp5w2l306
         xNyAFJYAtfpPY1qbsQIPw9UYYPMmr1Yx6AJO1+zfVn5g45KszwUfWlY/xQPOnfpLhJXs
         58o4+xk4a54ERG/RSANKzZUeoNIub3bQKe366JJaWKQdQcBKPWeafQ8yKcS5Uq7ivyng
         1WRUnwBT0VPOX6CXmdJySd4qktPLcnab48uj5vVGopKgvHPuUpCXbu8Bqj/7af9n+zD1
         S+6Q/yX0CynHeBVbnERkjqqmPpjImwDST9rE+y6NmJNqVLWSvN7VvaMUcxZgcxasFMyL
         FacA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id j123si6148879pgc.16.2019.02.06.09.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:20:13 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Feb 2019 09:20:08 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,340,1544515200"; 
   d="scan'208";a="114187766"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga006.jf.intel.com with ESMTP; 06 Feb 2019 09:20:07 -0800
Date: Wed, 6 Feb 2019 10:19:37 -0700
From: Keith Busch <keith.busch@intel.com>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>, linuxarm@huawei.com
Subject: Re: [PATCHv5 00/10] Heterogeneuos memory node attributes
Message-ID: <20190206171935.GJ28064@localhost.localdomain>
References: <20190124230724.10022-1-keith.busch@intel.com>
 <20190206123100.0000094a@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206123100.0000094a@huawei.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 12:31:00PM +0000, Jonathan Cameron wrote:
> On Thu, 24 Jan 2019 16:07:14 -0700
> Keith Busch <keith.busch@intel.com> wrote:
> 
> 1) It seems this version added a hard dependence on having the memory node
>    listed in the Memory Proximity Domain attribute structures.  I'm not 100%
>    sure there is actually any requirement to have those structures. If you aren't
>    using the hint bit, they don't convey any information.  It could be argued
>    that they provide info on what is found in the other hmat entries, but there
>    is little purpose as those entries are explicit in what the provide.
>    (Given I didn't have any of these structures and things  worked fine with
>     v4 it seems this is a new check).

Right, v4 just used the node(s) with the highest performance. You mentioned
systems having nodes with different performance, but no winner across all
attributes, so there's no clear way to rank these for access class linkage.
Requiring an initiator PXM present clears that up.

Maybe we can fallback to performance if the initiator pxm isn't provided,
but the ranking is going to require an arbitrary decision, like prioritize
latency over bandwidth.
 
>    This is also somewhat inconsistent.
>    a) If a given entry isn't there, we still get for example
>       node4/access0/initiators/[read|write]_* but all values are 0.
>       If we want to do the check you have it needs to not create the files in
>       this case.  Whilst they have no meaning as there are no initiators, it
>       is inconsistent to my mind.
> 
>    b) Having one "Memory Proximity Domain attribute structure" for node 4 linking
>       it to node0 is sufficient to allow
>       node4/access0/initiators/node0
>       node4/access0/initiators/node1
>       node4/access0/initiators/node2
>       node4/access0/initiators/node3
>       I think if we are going to enforce the presence of that structure then only
>       the node0 link should exist.

We'd link the initiator pxm in the Address Range Structure, and also any
other nodes with identical performance access. I think that makes sense.
 
> 2) Error handling could perhaps do to spit out some nasty warnings.
>    If we have an entry for nodes that don't exist we shouldn't just fail silently,
>    that's just one example I managed to trigger with minor table tweaking.
> 
> Personally I would just get rid of enforcing anything based on the presence of
> that structure.


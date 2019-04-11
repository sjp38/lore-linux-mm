Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E5CDC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7D122084D
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:22:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7D122084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 618236B026B; Thu, 11 Apr 2019 14:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59FF86B026C; Thu, 11 Apr 2019 14:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 467546B026D; Thu, 11 Apr 2019 14:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E8E026B026B
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:22:23 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so3565254edr.19
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:22:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=y6BbQw+t8nUtNL9E+M+Ca0ZOhHpnkjkb6OsUGCwrwpA=;
        b=gfDAIKTINpmU/lQNYkHRkHsWw7DTuMRpptm0C2MXv9Xbrlb7Ai83U1iVEhT8hjyaWz
         9RiieGE6NK6Q9LVqLTtKaP/FWhj/VT0LPKtyNyW2LJGX6cikgj8+mRuBPzhcmQPMdq6c
         m549wzUpwSEw8Exr8KCN/m1eeBjnwa72EqJkRWTD5V3aEnGfl5QigE8t+oJsN0aNZkvs
         C3EZkFFHnnPKXPhX4pajISrrCFJWNunw08VjFhv838HaZijMhKe8Gat9tCkigm9hvuxr
         aUGu5mMD/6qu/Q/wEi/2jIqvs1ru6TDKzim+xnTMY6b/wB7MwyivvnCIfeWWrZ9kBzln
         RR2w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX3p03btAU3MaDc849VonOz62r2Pj+zPyxd6VjEW3iqabHzLibY
	uVFuAmbKnNUH62U6AW3IrkrHOi70YumYK9ay25hUjIaGahHsy5dDhT/P95bzDYHM3mawaqulzyl
	CMW58e6Tc2fQLg89RBHF2otSSrG5zaKwcl3K6060KJg9VF7sd5HUF7qhfLFsfBrM=
X-Received: by 2002:a50:b582:: with SMTP id a2mr33028290ede.268.1555006943494;
        Thu, 11 Apr 2019 11:22:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3MJ57Xtj9WmpFo8UApPm/UDycmNXDa+f7ilHA9SiE4/Bv6clytRaq0BlPD3CGKcl5hRpI
X-Received: by 2002:a50:b582:: with SMTP id a2mr33028237ede.268.1555006942695;
        Thu, 11 Apr 2019 11:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555006942; cv=none;
        d=google.com; s=arc-20160816;
        b=NAtfww2LQmx0H0zQJuX7jN/dCSpqe0BSpuzUfunlNFCZuHGrIAhvSALPFhn65sdG42
         iY05id9vUPOYiTbUwp8clMLY98NmSeq5noJSMnNUjWUn93BBqP3gHDEVbg9WKNGwJo/b
         VvsgZ5CXHrIHbrzIWNA3uRtAsOx3dMKlatf0xp/trcrrdOPNWN5MJFb/mR8dpNZb+MRC
         jVSLzFHDKgyLFbsaP6rjDf1B65XSKKa0p0ZOKHd1b4vSTz/BvtjapabP53DLcT9HecjI
         uartF7F8yzF/bUZwbqNbMCfDPkk+NKZ2WPQ4V6NXHTvRbyKbtOqERZYwsx3pfv0Pti75
         mb2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=y6BbQw+t8nUtNL9E+M+Ca0ZOhHpnkjkb6OsUGCwrwpA=;
        b=hjwsgg8k6JFP7EznsiLkykFN0Hs+mwTq+wp0+wLVDbK1uywKvABvIu8VhSYTCLUlpC
         KoXM2ViFHdjoVJRBA1Nu1+TtUXwPmFSZf0pPYiejpkASNRH9y1of0Bph7w4obgOACV35
         1HfY2Kkx5eNxnoQS9H6nvrWEnENEXUS8SW8elLeEb4E/QIlYsTwnEE9W+/3lxVz51Wdi
         Or8B/ey3S70ezVI/7HP1GZG0mpVoBLeJ+A64N2c7nekz2Xp79p0pDvoijp6qdJBIiUUw
         LINh0ywDUfEjZbvQZaK3Y2Co6bD9pwzaYvr1iGj7cUJWWS8n9Iisk+HCUlf4D2WYP7Wb
         b1OA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k44si3323699ede.102.2019.04.11.11.22.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 11:22:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 3AC1DAD81;
	Thu, 11 Apr 2019 18:22:22 +0000 (UTC)
Date: Thu, 11 Apr 2019 20:22:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org,
	kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com
Subject: Re: [PATCH v2] hugetlbfs: fix protential null pointer dereference
Message-ID: <20190411182220.GD10383@dhcp22.suse.cz>
References: <20190411035318.32976-1-yuyufen@huawei.com>
 <20190411081900.GP10383@dhcp22.suse.cz>
 <b3287006-2d80-8ead-ea63-2047fc5ef602@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b3287006-2d80-8ead-ea63-2047fc5ef602@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 09:52:45, Mike Kravetz wrote:
> On 4/11/19 1:19 AM, Michal Hocko wrote:
> > On Thu 11-04-19 11:53:18, Yufen Yu wrote:
> >> This patch can avoid protential null pointer dereference for resv_map.
> >>
> >> As Mike Kravetz say:
> >>     Even if we can not hit this condition today, I still believe it
> >>     would be a good idea to make this type of change.  It would
> >>     prevent a possible NULL dereference in case the structure of code
> >>     changes in the future.
> > 
> > What kind of change would that be and wouldn't it require much more
> > changes?
> > 
> > In other words it is not really clear why is this an improvement. Random
> > checks for NULL that cannot happen tend to be more confusing long term
> > because people will simply blindly follow them and build a cargo cult
> > around.
> 
> Since that was my comment, I should reply.
> 
> You are correct in that it would require significant changes to hit this
> issue.  I 'think' Yufen Yu came up with this patch by examining the hugetlbfs
> code and noticing that this is the ONLY place where we do not check for
> NULL.  Since I knew those other NULL checks were required, I was initially
> concerned about this situation.  It took me some time and analysis to convince
> myself that this was OK.  I don't want to make someone else repeat that.
> Perhaps we should just comment this to avoid any confusion?
> 
> /*
>  * resv_map can not be NULL here.  hugetlb_reserve_pages is only called from
>  * two places:
>  * 1) hugetlb_file_setup. In this case the inode is created immediately before
>  *    the call with S_IFREG.  Hence a regular file so resv_map created.
>  * 2) hugetlbfs_file_mmap called via do_mmap.  In do_mmap, there is the
>  *    following check:
>  *      if (!file->f_op->mmap)
>  *              return -ENODEV;
>  *    hugetlbfs_get_inode only assigns hugetlbfs_file_operations to S_IFREG
>  *    inodes.  Hence, resv_map will not be NULL.
>  */
> 
> Or, do you think that is too much?
> Ideally, that comment should have been added as part of 58b6e5e8f1ad
> ("hugetlbfs: fix memory leak for resv_map") as it could cause one to wonder
> if resv_map could be NULL.

I would much rather explain a comment explaining _when_ inode_resv_map
might return NULL than add checks just to be sure.
-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8607C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 07:39:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A5BD02081B
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 07:39:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A5BD02081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=canonical.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42C528E0004; Fri,  8 Mar 2019 02:39:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3DC128E0002; Fri,  8 Mar 2019 02:39:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A4B88E0004; Fri,  8 Mar 2019 02:39:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C98EE8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 02:39:54 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id b9so9831012wrw.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 23:39:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=JJc0aaYe86uBtyFNHwS97nDpP6ya73K7Xpte85VT6jM=;
        b=JIOhm3o7dLHIHPfvCZGtCToLqlKz94DynOF9TIoIOjq3Bn5wDAOtrY1UaJSFpm3ztu
         iMA5PcjW+xqmurNFp9mmsz8Q6FOh9sWuLJjywg/gxizVFwPglCx4wBPt4vgzTufvPc0d
         RolNCiaoVUmSZ1PuVQsGRDsXocrTSNuM1e7p7dzS2/N4BOgZT9rhi4xwEVrjA+oQJB5V
         NicjDWd52XOug0nQmh3QwcIS9sd3mxdImCg5qg6a2MA9xXCJ/omKI9kD2Aeyj0KCE9rn
         BcgOxrlw75y7RTdHaogPwomeIP81K7S8vawpqdwNRVspQQR5ciKDF5J5pYrTGZFCXUk+
         8Cew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
X-Gm-Message-State: APjAAAW5zz8KCZUbQEtJsIDNYyCNn29xtNX8ZjpXFr/fjNzDboQlfBKR
	6ZyQadtDbIUsnYfgXkJ7Rxv3mym4+2wC74z6P8R4A+0eV8QPFjfX3FkBNxUABwbQofMi4mZS53+
	J4hwoL42Lw9wX8JQrPOdL21P5WjbkhWu2HwziL3JTbirNWNbJcbNxuZZX3u9rGXhqJIQTiV9y5g
	+PONqrI6SG1bVxzmp/t3dXYeTR7VRBzXY0D1FBktTOr85XWxn8difGC5JLlKgJHqJjo8z1wM1B5
	71PEqlAhyOjMfPLj5ndSCTKGanc9KtvrzzTElKTlUp3y1sOvFgBIyjKCzxNIUtHdO5hffF5SapT
	SpA8lLIh99okcKWO7r7fUtBR7cyFRMK64H+WCIIhl5zRyHNqGD4eUb2ibJcUnFpYVDP46M0fpH7
	KHXD+h8FIM+0ZsuJsUufO+84o56OmtePb0agBnqAYc0sae5ntxzV/y+IKIdAdXxh6QN6j7kNPnA
	Q9lYA5s1nqJoefCwnOCIOfJHrd93OA44uwMrP6EObCPmpAIcAvtnDkPITpENfHrLv7YwPb+9XKK
	Gpl/2v1HrWaK9M4w00ibeByTO4oZVojeESFybZ7LJq9Je9t0oNq9a8dFumI4jC57KgHoKRAi+ys
	A52mlePCvRPj
X-Received: by 2002:a1c:b403:: with SMTP id d3mr8006301wmf.85.1552030794322;
        Thu, 07 Mar 2019 23:39:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqxIkN7nJlpIlYe00ujsrQeJTuHbCaZkDiKHodvcVTKZHWxbs7sIjGhRlDTZAykTt2N32LDG
X-Received: by 2002:a1c:b403:: with SMTP id d3mr8006255wmf.85.1552030793528;
        Thu, 07 Mar 2019 23:39:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552030793; cv=none;
        d=google.com; s=arc-20160816;
        b=jmfCM4LNFdHujhslJj9LKaN9yattFPZON608ZauRb3e/aFJHz2WUuB52rmSAh/3c7V
         tknBc2Y9zUgohZTjUV4Oi2HLGoxPMjEPLcZSdescVBPDesfDON2d9X09TDpAQ5LF6pOj
         v+RcfokTxYGpP/1XLeg+yUGDrkJIW55E+E0aDxxO5EYxlAOAiYAIJgWFctshfQpOy8IC
         b78pig6LLw1W5Zf1IqkxXUEi/t/vIQjX/YvqG/G/sVMgScm2qk3esdxIJ9Bodkr8qsVM
         Wdm74KcZcBvBgVvMHKIqMEghHiOwG7ZN1s+InBBbL/xOotgnwDBUkPmApxWU5RRGwq51
         G/AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=JJc0aaYe86uBtyFNHwS97nDpP6ya73K7Xpte85VT6jM=;
        b=xImJ6HoVB8esj4ZgCGHNYKyOMGmBDDInepEft/h+kJ6KrKz/8JYExCEUAqEFl7yecY
         WMEs4v0lAkHDbpj+Bjn5/82gXqChmbc9UWG7oeDQ58kKajgNcpv8eGngzSxP58fKHXdA
         LZlmrm0ladYCzrOeva/fuWzbT+tNiqaqgL0J5tISiUBw8qXxDy0aXoBYSTBgAoSFQ74Z
         D4LY+KTCEGf3fkwj+nDF0JRGfjoxdje11q52YYDbmLsHStgZ3JfJNs/mjBXNGJikoHRu
         GGGSnrPRCOdofz32DkDhgRs7szZ9F3VbgE9tNkOV9Wo8RMJzeVKoIQZwLtMF/mqdrEjw
         R6QA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from youngberry.canonical.com (youngberry.canonical.com. [91.189.89.112])
        by mx.google.com with ESMTPS id m7si4396853wmc.171.2019.03.07.23.39.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Mar 2019 23:39:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) client-ip=91.189.89.112;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of andrea.righi@canonical.com designates 91.189.89.112 as permitted sender) smtp.mailfrom=andrea.righi@canonical.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=canonical.com
Received: from mail-wm1-f70.google.com ([209.85.128.70])
	by youngberry.canonical.com with esmtps (TLS1.0:RSA_AES_128_CBC_SHA1:16)
	(Exim 4.76)
	(envelope-from <andrea.righi@canonical.com>)
	id 1h2A6j-000349-3W
	for linux-mm@kvack.org; Fri, 08 Mar 2019 07:39:53 +0000
Received: by mail-wm1-f70.google.com with SMTP id t190so3865521wmt.8
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 23:39:53 -0800 (PST)
X-Received: by 2002:a05:600c:246:: with SMTP id 6mr8339774wmj.150.1552030792764;
        Thu, 07 Mar 2019 23:39:52 -0800 (PST)
X-Received: by 2002:a05:600c:246:: with SMTP id 6mr8339760wmj.150.1552030792587;
        Thu, 07 Mar 2019 23:39:52 -0800 (PST)
Received: from localhost (host22-124-dynamic.46-79-r.retail.telecomitalia.it. [79.46.124.22])
        by smtp.gmail.com with ESMTPSA id 203sm9224529wme.30.2019.03.07.23.39.51
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 23:39:52 -0800 (PST)
Date: Fri, 8 Mar 2019 08:39:50 +0100
From: Andrea Righi <andrea.righi@canonical.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Paolo Valente <paolo.valente@linaro.org>,
	Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>,
	Vivek Goyal <vgoyal@redhat.com>, Dennis Zhou <dennis@kernel.org>,
	cgroups@vger.kernel.org, linux-block@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 3/3] blkcg: implement sync() isolation
Message-ID: <20190308073950.GA6087@xps-13>
References: <20190307180834.22008-1-andrea.righi@canonical.com>
 <20190307180834.22008-4-andrea.righi@canonical.com>
 <20190307220659.5qmye2pxmto7nlei@macbook-pro-91.dhcp.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307220659.5qmye2pxmto7nlei@macbook-pro-91.dhcp.thefacebook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 05:07:01PM -0500, Josef Bacik wrote:
> On Thu, Mar 07, 2019 at 07:08:34PM +0100, Andrea Righi wrote:
> > Keep track of the inodes that have been dirtied by each blkcg cgroup and
> > make sure that a blkcg issuing a sync() can trigger the writeback + wait
> > of only those pages that belong to the cgroup itself.
> > 
> > This behavior is applied only when io.sync_isolation is enabled in the
> > cgroup, otherwise the old behavior is applied: sync() triggers the
> > writeback of any dirty page.
> > 
> > Signed-off-by: Andrea Righi <andrea.righi@canonical.com>
> > ---
> >  block/blk-cgroup.c         | 47 ++++++++++++++++++++++++++++++++++
> >  fs/fs-writeback.c          | 52 +++++++++++++++++++++++++++++++++++---
> >  fs/inode.c                 |  1 +
> >  include/linux/blk-cgroup.h | 22 ++++++++++++++++
> >  include/linux/fs.h         |  4 +++
> >  mm/page-writeback.c        |  1 +
> >  6 files changed, 124 insertions(+), 3 deletions(-)
> > 
> > diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
> > index 4305e78d1bb2..7d3b26ba4575 100644
> > --- a/block/blk-cgroup.c
> > +++ b/block/blk-cgroup.c
> > @@ -1480,6 +1480,53 @@ void blkcg_stop_wb_wait_on_bdi(struct backing_dev_info *bdi)
> >  	spin_unlock(&blkcg_wb_sleeper_lock);
> >  	rcu_read_unlock();
> >  }
> > +
> > +/**
> > + * blkcg_set_mapping_dirty - set owner of a dirty mapping
> > + * @mapping: target address space
> > + *
> > + * Set the current blkcg as the owner of the address space @mapping (the first
> > + * blkcg that dirties @mapping becomes the owner).
> > + */
> > +void blkcg_set_mapping_dirty(struct address_space *mapping)
> > +{
> > +	struct blkcg *curr_blkcg, *blkcg;
> > +
> > +	if (mapping_tagged(mapping, PAGECACHE_TAG_WRITEBACK) ||
> > +	    mapping_tagged(mapping, PAGECACHE_TAG_DIRTY))
> > +		return;
> > +
> > +	rcu_read_lock();
> > +	curr_blkcg = blkcg_from_current();
> > +	blkcg = blkcg_from_mapping(mapping);
> > +	if (curr_blkcg != blkcg) {
> > +		if (blkcg)
> > +			css_put(&blkcg->css);
> > +		css_get(&curr_blkcg->css);
> > +		rcu_assign_pointer(mapping->i_blkcg, curr_blkcg);
> > +	}
> > +	rcu_read_unlock();
> > +}
> > +
> > +/**
> > + * blkcg_set_mapping_clean - clear the owner of a dirty mapping
> > + * @mapping: target address space
> > + *
> > + * Unset the owner of @mapping when it becomes clean.
> > + */
> > +
> > +void blkcg_set_mapping_clean(struct address_space *mapping)
> > +{
> > +	struct blkcg *blkcg;
> > +
> > +	rcu_read_lock();
> > +	blkcg = rcu_dereference(mapping->i_blkcg);
> > +	if (blkcg) {
> > +		css_put(&blkcg->css);
> > +		RCU_INIT_POINTER(mapping->i_blkcg, NULL);
> > +	}
> > +	rcu_read_unlock();
> > +}
> >  #endif
> >  
> 
> Why do we need this?  We already have the inode_attach_wb(), which has the
> blkcg_css embedded in it for whoever dirtied the inode first.  Can we not just
> use that?  Thanks,
> 
> Josef

I'm realizing only now that inode_attach_wb() also has blkcg embedded
in addition to the memcg. I think I can use that and drop these
blkcg_set_mapping_dirty/clean()..

Thanks,
-Andrea


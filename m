Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBBFCC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:19:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EA752087F
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 11:19:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EA752087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 770008E0002; Tue, 29 Jan 2019 06:19:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F6A68E0001; Tue, 29 Jan 2019 06:19:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C00A8E0002; Tue, 29 Jan 2019 06:19:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1888C8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 06:19:39 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id q63so16619873pfi.19
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 03:19:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CcUY1XCS8x3U3DP20Z/UxvuiSpe/K6ouRRXm1ktp1VU=;
        b=HIJWaDlu1194Ljl7UeOI0mm6hYOZ6wJ5USzeoT00jV9oGMDAA7BE1BML73wRVR3hMn
         w//VmSeOLJs6LWaHjKLPkGRtFc4FNmJbS6wVcKc2NSpe4250o0DFzBdEyN0F+B72RCmb
         vz5c6SIvO6oQ9ZZlD1GwTELFfI4z13BR3gxrD6fCS1mEVXXwFpku7xRdaB/QYS2Y1zZj
         jv9BR7Crpg90e+Dt81bcF1LaevWwln9q1uO4gRGfZdFIGpIzPFlBN8xPk814p73XpUXn
         LsrdzHA5I0/5q/pmuDGs6Hm03/wcFH7ogm0uyGHgypQ6LjUDigL19it727nHNFgVoc8/
         UmZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: AJcUukcxdIX269B017eq+5ypv5aZprqONdPlrJMYOq+r8nS9j1gn0eJQ
	kusIRfb0Fp7QnMlaE76DYwr7ryrobeG/ooC2lRJiMzUDhKYvd6eHbTEI/DGWEiRgNvxbOYPKkGS
	H6RzLLV63VfbcmjdypmbHgu6/0on6rUV5LSkwVx3oZ9GybVCaceeolFuXmhW+dYvaDA==
X-Received: by 2002:a62:5e41:: with SMTP id s62mr25479698pfb.232.1548760778712;
        Tue, 29 Jan 2019 03:19:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Iv1VtvnL0k/aJqKLMDp2Q62Y+qTjg0WUm3ah8HmS9AhAWW8NNhNrPLqRlsOjPvH8d9QoH
X-Received: by 2002:a62:5e41:: with SMTP id s62mr25479649pfb.232.1548760777828;
        Tue, 29 Jan 2019 03:19:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548760777; cv=none;
        d=google.com; s=arc-20160816;
        b=G8+29T/Xl3K/03/t/YN6Rdiap0WDmEdJxzGoSatHrQvUkOTImpn8vcjgIPtm+2jQGR
         vfKT70VBUw78BOnB+RABTydGnSEtJi44uxis/EeEsbVtX743BhC5LQUpMM+t4rJs4LzO
         n3o5pUDM48uGlgGJ2kBGABIMUgz6Rx5mRaUG20iM9nPBMCLHzTT6E3YIEa7HeGXSKgIi
         nXZjC7WdlB1SvkudX+Md/eGlJCDzhWnaAEwW1OME0FdCZERCcH6NbfhT7yZPn29MIaFc
         bl0KRv/7gWc3h0x+NMTWyrWbVvszhHUfcljHz2iducOeAkkWjrbjV7MrtMQdPbOjFqH7
         j8Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CcUY1XCS8x3U3DP20Z/UxvuiSpe/K6ouRRXm1ktp1VU=;
        b=Ax5qFzzS0pUghDoYQoaZX9376PPe9sTfJdeurNNg+p72UybjyekNWHtJ/gJaeu+AWG
         CDn8auMIq3JomkK2+cBYtl5CDliJh9wu4UgoWQ4kOzmsCqov2Hv0LS70Wvo+n/sWtV9/
         Oqfr4yzCWEVbHP/Ub/DSHNHXe4tYuFvD4st2ZE5rraQ4KqF2Rz6QLuHJmUpzAwLgk01x
         JB3mbnFt4aVlgdXQGtwsIlqmG4VrRzI/qPb6LBb4h4pFcGUXTldP+hD6A/IxUHx0fqlY
         OFO1IO8CdcUhhsEBMm046wtdsdXZqk9ZJbllvM7kvFIRymyUSKwVJbOMdP2q9NgZXr+f
         iYpQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-42.freemail.mail.aliyun.com (out30-42.freemail.mail.aliyun.com. [115.124.30.42])
        by mx.google.com with ESMTPS id b19si37674564pfm.100.2019.01.29.03.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 03:19:37 -0800 (PST)
Received-SPF: pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.42 as permitted sender) client-ip=115.124.30.42;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aaron.lu@linux.alibaba.com designates 115.124.30.42 as permitted sender) smtp.mailfrom=aaron.lu@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R111e4;CH=green;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01353;MF=aaron.lu@linux.alibaba.com;NM=1;PH=DS;RN=6;SR=0;TI=SMTPD_---0TJD3541_1548760768;
Received: from h07e11201.sqa.eu95(mailfrom:aaron.lu@linux.alibaba.com fp:SMTPD_---0TJD3541_1548760768)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 29 Jan 2019 19:19:35 +0800
Date: Tue, 29 Jan 2019 19:19:28 +0800
From: Aaron Lu <aaron.lu@linux.alibaba.com>
To: Joseph Qi <joseph.qi@linux.alibaba.com>
Cc: Jiufei Xue <jiufei.xue@linux.alibaba.com>, akpm@linux-foundation.org,
	linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
	Vasily Averin <vvs@virtuozzo.com>
Subject: Re: [PATCH] mm: fix sleeping function warning in alloc_swap_info
Message-ID: <20190129111928.GA90734@h07e11201.sqa.eu95>
References: <20190129072154.63783-1-jiufei.xue@linux.alibaba.com>
 <f174c414-ed81-11a7-02cd-b024ef75d61f@linux.alibaba.com>
 <d1bb1729-e742-6d30-539d-5b45cc1ddb72@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d1bb1729-e742-6d30-539d-5b45cc1ddb72@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 06:43:53PM +0800, Joseph Qi wrote:
> Hi,
> 
> On 19/1/29 16:53, Aaron Lu wrote:
> > On 2019/1/29 15:21, Jiufei Xue wrote:
> >> Trinity reports BUG:
> >>
> >> sleeping function called from invalid context at mm/vmalloc.c:1477
> >> in_atomic(): 1, irqs_disabled(): 0, pid: 12269, name: trinity-c1
> >>
> >> [ 2748.573460] Call Trace:
> >> [ 2748.575935]  dump_stack+0x91/0xeb
> >> [ 2748.578512]  ___might_sleep+0x21c/0x250
> >> [ 2748.581090]  remove_vm_area+0x1d/0x90
> >> [ 2748.583637]  __vunmap+0x76/0x100
> >> [ 2748.586120]  __se_sys_swapon+0xb9a/0x1220
> >> [ 2748.598973]  do_syscall_64+0x60/0x210
> >> [ 2748.601439]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> >>
> >> This is triggered by calling kvfree() inside spinlock() section in
> >> function alloc_swap_info().
> >> Fix this by moving the kvfree() after spin_unlock().
> > 
> > The fix looks good to me.
> > 
> > BTW, swap_info_struct's size has been reduced to its original size:
> > 272 bytes by commit 66f71da9dd38("mm/swap: use nr_node_ids for
> > avail_lists in swap_info_struct"). I didn't use back kzalloc/kfree
> > in that commit since I don't see any any harm by keep using
> > kvzalloc/kvfree, but now looks like they're causing some trouble.
> > 
> > So what about using back kzalloc/kfree for swap_info_struct instead?
> > Can save one local variable and using kvzalloc/kvfree for a struct
> > that is 272 bytes doesn't really have any benefit.
> > 
> avail_lists in swap_info_struct is dynamic allocated.
> So if we use back kzalloc/kfree, how to deal with the case that
> nr_node_ids is big?

Oh right, I missed that.

Acked-by: Aaron Lu <aaron.lu@linux.alibaba.com>
 
Thanks,
Aaron
 
> >>
> >> Fixes: 873d7bcfd066 ("mm/swapfile.c: use kvzalloc for swap_info_struct allocation")
> >> Cc: <stable@vger.kernel.org>
> >> Reviewed-by: Joseph Qi <joseph.qi@linux.alibaba.com>
> >> Signed-off-by: Jiufei Xue <jiufei.xue@linux.alibaba.com>
> >> ---
> >>  mm/swapfile.c | 6 ++++--
> >>  1 file changed, 4 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/swapfile.c b/mm/swapfile.c
> >> index dbac1d49469d..d26c9eac3d64 100644
> >> --- a/mm/swapfile.c
> >> +++ b/mm/swapfile.c
> >> @@ -2810,7 +2810,7 @@ late_initcall(max_swapfiles_check);
> >>  
> >>  static struct swap_info_struct *alloc_swap_info(void)
> >>  {
> >> -	struct swap_info_struct *p;
> >> +	struct swap_info_struct *p, *tmp = NULL;
> >>  	unsigned int type;
> >>  	int i;
> >>  	int size = sizeof(*p) + nr_node_ids * sizeof(struct plist_node);
> >> @@ -2840,7 +2840,7 @@ static struct swap_info_struct *alloc_swap_info(void)
> >>  		smp_wmb();
> >>  		nr_swapfiles++;
> >>  	} else {
> >> -		kvfree(p);
> >> +		tmp = p;
> >>  		p = swap_info[type];
> >>  		/*
> >>  		 * Do not memset this entry: a racing procfs swap_next()
> >> @@ -2853,6 +2853,8 @@ static struct swap_info_struct *alloc_swap_info(void)
> >>  		plist_node_init(&p->avail_lists[i], 0);
> >>  	p->flags = SWP_USED;
> >>  	spin_unlock(&swap_lock);
> >> +	kvfree(tmp);
> >> +
> >>  	spin_lock_init(&p->lock);
> >>  	spin_lock_init(&p->cont_lock);
> >>  
> >>


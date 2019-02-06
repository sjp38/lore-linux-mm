Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81912C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:17:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2406E2175B
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 17:17:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2406E2175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 798618E00D7; Wed,  6 Feb 2019 12:17:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 747BA8E00D1; Wed,  6 Feb 2019 12:17:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E94A8E00D7; Wed,  6 Feb 2019 12:17:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 30C5F8E00D1
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 12:17:45 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id 124so3902665ybl.10
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 09:17:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ji4OoP4gZb0UHEOnXg3A/jf29KxDb933tTdUBJ4XTb8=;
        b=stCzz1sWpwCBq3RLciZPfjbSS6N/9yvxMA/AyyJ2cmOyvdnZqTyhl6EFa9heOw7wno
         vGK+0nKD5xLBOtkTLqg2Hmy2X1LrNtic9h/a5oJCZxWk8rTJzB4s/7mR+XwQEx4CVIMZ
         aY2bYnNwntAB4Tmf+FgKjBuBlvYeLY3O4k+aYI7d1nJbJcU/+M4Ri7hQlHUQLgMONeni
         lv+4/IN1kQJO/tmy4lx8rWaf+d96cpvfRDdDPdjnzlSTvPoIqavTaU7X7fFxCj/GewJ6
         0L4C457YriPablQQSJsbXPPyLk6hautVL6sUpb7Ap0PC4XJQitf5VIgxhcycrGVS3tMc
         LuGw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaPmX+Xzbmm5hxjdZYoYs95ypiwg5Iir8EPPkl3RFG85iXBPFGj
	wNij6AMb/ozM3cS2txZ3oJ0dYz8BxBas1ZL0hw9S57IJ2pL8fBsc6Oft7gQjxRMOr0ph8dCHHer
	RKtIQxDbUu4hes7tWhrkvpINfFEfRLcElAauFBxulzPhpUmp1SOccdU1HL8T0u1CMHgQSdySxMR
	bxgDTdgVtyWVjhy/8AdKl9/oDW1b+gGG/S3grWudTmT6LCLmNVUYE5C6xLh2zWNY2m4fn1Mpnpq
	joRbeAvyP1vF5+/aM4lbZv/VBhq4e4JlMQUgvS//QAPl1b3TlB+dat2mc6aSz7Aq7Nk4V5a1TN4
	V2vH6Y8+mWjRWdWIKe5+eyBojckFwVN8hIFruWMHWVj+am/vf3OIkDUbwTm1q9prXZTw5qiSKw=
	=
X-Received: by 2002:a81:de09:: with SMTP id k9mr9451606ywj.384.1549473464787;
        Wed, 06 Feb 2019 09:17:44 -0800 (PST)
X-Received: by 2002:a81:de09:: with SMTP id k9mr9451546ywj.384.1549473464156;
        Wed, 06 Feb 2019 09:17:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549473464; cv=none;
        d=google.com; s=arc-20160816;
        b=Vb319Xs0TvW+qaYatRbNdSHS5EH40SrR91Ez/PJD5q6vSFMs+3/bx8QS4b8p8dxDcm
         H9lv+qT2BVAeNzRJNBd6+PMCV/WQcG9hGaRMPpH3syeIf+NE4ipBlLl4J9/+668ktTdg
         oC9nZ3fDhMqc3UqnTA3a7Tm+NyEIwXnKAGXst+GCe1pLYgx/HDpBYHpAwj4bjVzERZCl
         zZCnLZZCz862WAj8FAwycHx35TBAakCozOhCotmXTn15pST1CLFMHEVdStqTiJIQkjZ3
         62OEjx140EvEUWz2YefLcBDQb8ERJWXGfTZPu6YqclZGyQATpD0qVbN9eUqcH9fd0taU
         h+Bg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ji4OoP4gZb0UHEOnXg3A/jf29KxDb933tTdUBJ4XTb8=;
        b=nJRlPe6YD67/D44jgxe1AYPramNBlFNU7bLigrwvl+YzfMVkZwaz6oqSHTCUUQf9K1
         +JN9rjmKXXxH7mIjf5sX0U/ioh4z9AVK0bMHzaOiHbjCJC7utYJ0NQwDDwve/cGqZNud
         7mAV+aNP4be8IEHQjK7DxCV6QTNpyv0x46UWVflcRSERy5bALcrPBUXo3sFtxsihzqLM
         PdApi6GaubjxIj9usjIYG32cQxdqwdMik+W6QcZRztRzEIU9R6LiKCcRqOOLgdoyPuUF
         eUV6S7y1NmNQf3MIu9AKYpcTGWZbWGBTw2tsUeV3ghbzVJA8DpwCbs6RC/Tf/sA9FYCW
         2G6w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l67sor2666149ybl.204.2019.02.06.09.17.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 09:17:44 -0800 (PST)
Received-SPF: pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dennisszhou@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dennisszhou@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZO9T7Bd/cFH3OwnLQYXkyAn0cAcxj3WTyYyZnGXp3FiezPA4csefBRbReutDprdGua+1zahQ==
X-Received: by 2002:a25:ac2:: with SMTP id 185mr9334157ybk.349.1549473463791;
        Wed, 06 Feb 2019 09:17:43 -0800 (PST)
Received: from dennisz-mbp.dhcp.thefacebook.com ([2620:10d:c091:200::6:c448])
        by smtp.gmail.com with ESMTPSA id k142sm2525624ywa.67.2019.02.06.09.17.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 09:17:42 -0800 (PST)
Date: Wed, 6 Feb 2019 12:17:40 -0500
From: Dennis Zhou <dennis@kernel.org>
To: Peng Fan <peng.fan@nxp.com>
Cc: "dennis@kernel.org" <dennis@kernel.org>,
	"tj@kernel.org" <tj@kernel.org>, "cl@linux.com" <cl@linux.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Subject: Re: pcpu_create_chunk in percpu-km
Message-ID: <20190206171740.GA76990@dennisz-mbp.dhcp.thefacebook.com>
References: <AM0PR04MB44813C69CCAE720A47164EA8886F0@AM0PR04MB4481.eurprd04.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AM0PR04MB44813C69CCAE720A47164EA8886F0@AM0PR04MB4481.eurprd04.prod.outlook.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Peng,

On Wed, Feb 06, 2019 at 12:23:44PM +0000, Peng Fan wrote:
> Hi,
> 
> I am reading the percpu-km source code and found that in
> pcpu_create_chunk, only pcpu_group_sizes[0] is taken into
> consideration, I am wondering why other pcpu_group_sizes[x]
> are not used?
> 
> Is the following piece code the correct logic?
> 
> @@ -47,12 +47,15 @@ static void pcpu_depopulate_chunk(struct pcpu_chunk *chunk,
> 
>  static struct pcpu_chunk *pcpu_create_chunk(gfp_t gfp)
>  {
> -       const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
> +       int nr_pages = 0;
>         struct pcpu_chunk *chunk;
>         struct page *pages;
>         unsigned long flags;
>         int i;
> 
> +       for (i = 0; i < pcpu_nr_groups; i++)
> +               nr_pages += pcpu_group_sizes[i] >> PAGE_SHIFT;
> +
>         chunk = pcpu_alloc_chunk(gfp);
>         if (!chunk)
>                 return NULL;
> 
> Thanks,
> Peng.
> 

The include for percpu-km.c vs percpu-vm.c is based on
CONFIG_NEED_PER_CPU_KM. This is set in mm/Kconfig which is dependent on
!SMP. Given that, it will only be called with the UP (uniprocessor)
version of setup_per_cpu_areas() which inits based on
pcpu_alloc_alloc_info(1, 1).  So, because of this, we know there will
not be other groups. In the UP case, percpu just identity maps percpu
variables.

Thanks,
Dennis


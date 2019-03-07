Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57656C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:47:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA8CC20652
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:47:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA8CC20652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 727588E0007; Thu,  7 Mar 2019 10:47:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D7448E0002; Thu,  7 Mar 2019 10:47:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CA978E0007; Thu,  7 Mar 2019 10:47:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE2B8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 10:47:27 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id u66so1974868qkf.17
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 07:47:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=BhTxD3ySC1uQNcQaurRgNi8lE2OWakmfxk2tvcIPUn4=;
        b=l4Bu/sgbUCN1AR9Nx3xt4hg+oklHpmDNq/WEvk9UYjtAJWPpKTJklOkpi6gBgiOWcs
         HKQCiPUTkesDjS/+j2P2Df/F0qnWMe0gkMwrq9PxzetAILDM0OdJESGO95FiNvhScfeK
         QCzX246wJP7sS1o19JgbHx1iC7BZhk/FBKIRqkZgOD/Wyi4xf4FdDKVZGH+LM0qrbGKk
         BOOg5jX6M9j0tpy7rzuHQIF59Ah8jWEySD1yBZMxXRRDjgjYN8rvtokZsaHng+BUxBGU
         vM6he9+NJzD0QctuzBhiYEjyQoiLXjC61kc4fnJGIVAuYyIgJFMzWWKp4haD1Elvp3z1
         tHCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWOqV4ThBxGVr2HLYgFuVR/gnjqdDF22kwZhMTd1k2m7n07C9IM
	VeX4GKFkF1f30HQOsCHdHgdBuMazL0b0H3i3ZtGwhQIJGkUtbFyoFkyFVDPrBagqKyfbdGdOvQe
	f5xi1adZENPWwLIxj9WUZ0a19l97LkHmGJPdXSO/6OgSkZ4F0W+XdsljlDlV9AvVlyZSCL+QP9o
	d37LxqjdminAS9+pLECpGAl5niw/NlbcoYtmCdSkTcF8J8q/AbT92YSsuFaKyv87z0JrlnFOx1X
	MQIFseC0TafdMWNIKbVNIkerdd6+6DKaOeaf4bbwttzzu323xmbvX5EEEB8sZYekYi5FYubLl2d
	I3/8XQRlef20xlmxG/KW5f49Z2d7txQ1OAN1t1MdercmTmEw5Zniri5We/cJtqL8XyA/ck1xZNw
	X
X-Received: by 2002:ac8:30d3:: with SMTP id w19mr10767587qta.48.1551973646961;
        Thu, 07 Mar 2019 07:47:26 -0800 (PST)
X-Received: by 2002:ac8:30d3:: with SMTP id w19mr10767555qta.48.1551973646320;
        Thu, 07 Mar 2019 07:47:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551973646; cv=none;
        d=google.com; s=arc-20160816;
        b=IAwQSxaiFKMwvGMVJ1MKkmXDklPPD2ifq/eur+9RWff4x28wmMEHOO0V7PrqU2alfl
         /kyvpRpIf3gqOY5/R15EjzS8S5eg+AeR4eafipP8LHofCTcKV0C787ZCOIex3ATHwdKg
         t+C5gshYGSV5M6/jV0u6q9bJFovHoI2blVC90kN+Gt5Xd8lKDoxxkQ05bbqlfv9hWdzq
         aj+hqf1tLWffornMUjDhsRqkQ/rdeokxdJA4umM4pndTfVScfrMCUsYNHZK3Ii8QQowP
         k+ufDV9BNkxKu1dkFSNIq3BnUInc4leyaPr0nxovVSHYn3Ezoz8QTOIlxQtSiRPyMWig
         kdCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=BhTxD3ySC1uQNcQaurRgNi8lE2OWakmfxk2tvcIPUn4=;
        b=BxYUJw96rLrcO6A4aE/sAvJgacIEqiff0JjvreRXeN5TS4J/6DDrdN0dkkf3/Y9rC3
         JT8XUc4VENaz1NnEmbXKejrsPUjTP6evdFcb84KDsAhvfsnLhRs6sJWDE8oLlobVwK8Y
         QQLDDk8qZC4A0ZLRc9yiKY9Fl8m62YXqYvw1NNKo57m71YZ7EElwO7msuAWyOU9XW5sj
         Y/Jhy8rr+LzRlo4IjdJP2KQ5m2F+ceoFyNiKyymkqiSdR/lc8eVahaiwcthJNAueK6jD
         UelXRrefLpF9ep2Uhb/No6ThfLSoUrM0i3pJWP5SCrG+iaujLzMppOtBTgM1GYJOnvrn
         VcuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g66sor2793689qkb.134.2019.03.07.07.47.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 07:47:26 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwmzGcW5lj5Q8CC2/neDVhy2nmaELi4a1GVCRW653iKSH/SbNxUxxC4uElvkGE3ZhcVB5QJ0g==
X-Received: by 2002:a05:620a:148a:: with SMTP id w10mr10023352qkj.172.1551973646133;
        Thu, 07 Mar 2019 07:47:26 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id s49sm3115748qtk.7.2019.03.07.07.47.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 07:47:25 -0800 (PST)
Date: Thu, 7 Mar 2019 10:47:22 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307103503-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1551856692-3384-6-git-send-email-jasowang@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 06, 2019 at 02:18:12AM -0500, Jason Wang wrote:
> +static const struct mmu_notifier_ops vhost_mmu_notifier_ops = {
> +	.invalidate_range = vhost_invalidate_range,
> +};
> +
>  void vhost_dev_init(struct vhost_dev *dev,
>  		    struct vhost_virtqueue **vqs, int nvqs, int iov_limit)
>  {

I also wonder here: when page is write protected then
it does not look like .invalidate_range is invoked.

E.g. mm/ksm.c calls

mmu_notifier_invalidate_range_start and
mmu_notifier_invalidate_range_end but not mmu_notifier_invalidate_range.

Similarly, rmap in page_mkclean_one will not call
mmu_notifier_invalidate_range.

If I'm right vhost won't get notified when page is write-protected since you
didn't install start/end notifiers. Note that end notifier can be called
with page locked, so it's not as straight-forward as just adding a call.
Writing into a write-protected page isn't a good idea.

Note that documentation says:
	it is fine to delay the mmu_notifier_invalidate_range
	call to mmu_notifier_invalidate_range_end() outside the page table lock.
implying it's called just later.

-- 
MST


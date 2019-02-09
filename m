Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30BDEC282CB
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 13:52:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDAB22192B
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 13:52:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ho854t0V"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDAB22192B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 214F28E00CA; Sat,  9 Feb 2019 08:52:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C3FD8E00C5; Sat,  9 Feb 2019 08:52:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0DACF8E00CA; Sat,  9 Feb 2019 08:52:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABCB18E00C5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 08:52:35 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id g3so3060325wmf.1
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 05:52:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=a1FxRbJ08wKgp4Co0znQWeKyAEWRpt3r5CDQgl/lzA4=;
        b=s1QvM/7JuqXNCl7mDYiaTBqSIEKNqpjWSmvM9Ffs+XuEnv9crSQW/qLc2u16RgSfDi
         94oOWBqfpiyzjeAx+w9csLAdF1YIxtZCjDE+7N1A8alpesU8Y3RinEwUzYwqxww/0KSx
         weqWHY/GUM7IhcSjmqvmuCsMH+FYuRYDnsW9IUmcemkdZ9GiJiAIBAsrJnqv51g+l7dt
         PVw5lJG2IIGvQDyHdAwO3bmW03LaUhNKZuRwqd/9mlkQ1gtNQwADcuNExyrtAZPh0e0M
         LbyFIbj6iZlzbdfaEHDbtPssF3IqzBGLct2ijZBvpvu28harWd2WN+aGdxg8zjRS7066
         hcIA==
X-Gm-Message-State: AHQUAuZCGWjKv6pfNju/K9atJPgUaGE+wpnsvBBJDPlQeMTQeoBHH/r/
	s+5VBE2JCogXJK8a6YGu0g2wEcLhi/MrXhn0BlUYHgnnyZAHP4XzE2ANFOTDI2j2LZxPrdrjthF
	54LQOlPeOqCsNOe5cyl665huyVbrXFXgRtTtOOMrunH2l35W4PxxXW/b60rlh5fuRFLhOGqASIZ
	KWgex1yIsKOKwKIecourAXrYJNTBy8aWLAdWeTcyYpJz/QQsrNrXULpmkYh7XJQ7+LF4j8iANqL
	Xvimwrn+PBn0M7yanHD/EGPUFmSFswKT+fbcrx3U4YTgyFjN+6W1yWXQelly+RkNCGKzHqfYujS
	FQp1PqSZjMuu0B6xq4MX6141A6xv/tqfNElayCs9fiHfla9mi1jXTQ3O8uVr6Naqcg8iFx1aaFR
	N
X-Received: by 2002:adf:ba8d:: with SMTP id p13mr15554860wrg.53.1549720355281;
        Sat, 09 Feb 2019 05:52:35 -0800 (PST)
X-Received: by 2002:adf:ba8d:: with SMTP id p13mr15554835wrg.53.1549720354453;
        Sat, 09 Feb 2019 05:52:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549720354; cv=none;
        d=google.com; s=arc-20160816;
        b=duWNE9vtKDJ8jzu4FxZZKMy8ywmFXGUA85ASL1uN0OSTgJBPj6Bfpfp8zQ5+0Bgmum
         rwnEijXnFU9Do3SlUTa0GLn/IpbyjyhOn1BYfun+fDklWzm9wIPtPhEbCwC7AjyV1nZK
         /fHboWMfzCf04k+8kP1g1quDJshPQ7RCTfuFi4J//2qvruroXHNt1rM4vfiFwZSLyqVy
         WGhfZzqLA8m8A2/cxKvkeWejX56e9W9Hqxj78gjPbFz1/FeiV2kV3yeJNuXit3AUztk7
         /OJlfZaltBsN1UeX2Z2b/qGnskYeQ2276BPs1tvcs67AY8E/Jwvi/1R9yIZZf8y7ROeT
         gsbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=a1FxRbJ08wKgp4Co0znQWeKyAEWRpt3r5CDQgl/lzA4=;
        b=DqZ8R/fPmCRaaqPE529QU5xSid3HLKhI+GSfXPiMjzt/Dhxd6TqaqOlHsIhyah65fC
         5NWwcbOiB+qUIu85U4VRIv1AbnsM1Qsce76cVCWn69dPES34yDQdxE5geAUz060ec1+N
         hTG0Fmj8EeSFRzks4Dtk6WAF1bk1qwSsaLDRUB7JI/TztbZ7xrjVlDdd9Z55WjEA8lYL
         ciBnUrZs5QE2uTisYNssOgBTA6oyvLy9OA8SgkFhy3jW0tiOFZDyLTAwNn/eRyRQ4uGl
         NTfYhQ/ukIIBDy8OWkKAkn3AMF/YTHhbyhyDnjDBu9aMv7rOe46zkWKmoLOmyQuXRykF
         pl2A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ho854t0V;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i4sor3071133wrx.38.2019.02.09.05.52.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 09 Feb 2019 05:52:34 -0800 (PST)
Received-SPF: pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ho854t0V;
       spf=pass (google.com: domain of righi.andrea@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=righi.andrea@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=a1FxRbJ08wKgp4Co0znQWeKyAEWRpt3r5CDQgl/lzA4=;
        b=ho854t0VeE6vkAj0xsMCBVg+GmgJHVfw5OjfuHOJNNggl2sV7EERA8YSfPVlbMvOI/
         8VfPfvbCOdKdg1UTWHM/i0jDat3tgSYv0ewqUWVbUABw4sOc26cXz78V1kDZdl0FeXcU
         fUUbDB73SdMwb9ZQit//tkf/yJmMy+BsmPYc5egWKEuM9+cJW5rYCz/vmSeWAyyx8Fsk
         hc27LyFIpXFFNT7f/0lYIbAdpujM488pot5HUf31+3kyX5gkm3JvloV91OtiSEWmXl4a
         S+ls75NLMEcJxwYPKh92JNiCRLHdMp4QjFpU7eGPGle1WxcJM7BvMOUeEOWjSkya9ZGO
         1TGw==
X-Google-Smtp-Source: AHgI3IYCGgyeMoumNCNf/hlgXlYmgnGoCIA2EAC1vCyg+s6hZ7Scw34UnmRgzD6RTx7omoGjVtJXAw==
X-Received: by 2002:adf:9004:: with SMTP id h4mr13476386wrh.121.1549720353621;
        Sat, 09 Feb 2019 05:52:33 -0800 (PST)
Received: from localhost ([95.238.120.247])
        by smtp.gmail.com with ESMTPSA id r12sm6648362wrt.76.2019.02.09.05.52.32
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 09 Feb 2019 05:52:32 -0800 (PST)
Date: Sat, 9 Feb 2019 14:52:31 +0100
From: Andrea Righi <righi.andrea@gmail.com>
To: Josef Bacik <josef@toxicpanda.com>
Cc: Paolo Valente <paolo.valente@linaro.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>,
	Jens Axboe <axboe@kernel.dk>, Vivek Goyal <vgoyal@redhat.com>,
	Dennis Zhou <dennis@kernel.org>, cgroups@vger.kernel.org,
	linux-block@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH] blkcg: prevent priority inversion problem during
 sync()
Message-ID: <20190209135231.GA1910@xps-13>
References: <20190209120633.GA2506@xps-13>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190209120633.GA2506@xps-13>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 09, 2019 at 01:06:33PM +0100, Andrea Righi wrote:
...
> +/**
> + * blkcg_wb_waiters_on_bdi - check for writeback waiters on a block device
> + * @bdi: block device to check
> + *
> + * Return true if any other blkcg is waiting for writeback on the target block
> + * device, false otherwise.
> + */
> +bool blkcg_wb_waiters_on_bdi(struct backing_dev_info *bdi)
> +{
> +	struct blkcg *blkcg, *curr_blkcg;
> +	bool ret = false;
> +
> +	if (unlikely(!bdi))
> +		return false;
> +
> +	rcu_read_lock();
> +	curr_blkcg = css_to_blkcg(task_css(current, io_cgrp_id));

Sorry, the logic is messed up here. We shouldn't get curr_blkcg from the
current task, because during writeback throttling the context is
obviously not the current task.

I'll post a new patch soon.

> +	list_for_each_entry_rcu(blkcg, &bdi->cgwb_waiters, cgwb_wait_node)
> +		if (blkcg != curr_blkcg) {
> +			ret = true;
> +			break;
> +		}
> +	rcu_read_unlock();
> +
> +	return ret;
> +}

-Andrea


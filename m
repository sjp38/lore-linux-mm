Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D8E3C10F00
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 02:46:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7AAA2064A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 02:46:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7AAA2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56F7B8E0003; Wed,  6 Mar 2019 21:46:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51EB78E0002; Wed,  6 Mar 2019 21:46:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 434E08E0003; Wed,  6 Mar 2019 21:46:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADE08E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 21:46:09 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id k1so13902411qta.2
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 18:46:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=V8y4Da7EC7/NkkBxiw9MiVHU1l5kq31Xn/NFenvOq/Q=;
        b=dvWqZtE0vTGSDfqdNCQQ6NnG+UY+l/qNHrwOJqSa7PSmHR+E+GLIhnBDCMVrmAl4Or
         FEGMIMfjR6vGZeMpmawCUvMGQ6iTpjF5AZbMYg26uxWlg+HBkLB522Jqyy1XO6EOjU3V
         +BD25jNgXglpzvbrp3PaCBjFdPmWACWCC5Cmwgg+x5OdfcPP32pgL4jKFFDg6Vodbxn+
         2SrFI9iadr2yuAfPZjbgQh+qwndYJHhJM/nDjKpUHQfB8CS8jsgxni0iqZH1hYoCEXA0
         Lbk3LFn+Dag7bEmqSAtaTd/TBpp+jtZnfQYFZU6F5OmiLcNN1XvDUauGBUTOy/pG7tnh
         3Psg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWxb5JsmX4VYcOxrAlax09d4yB9rmUOT3vg/VobmtA+g6PgHu1q
	Aet+gIbnaOGFa+E5OoBieR90PH2MZDAZNfvjEnfg74Ig3khgmQSbPqPo4y42qafZQp0eTtyruPS
	2jNGFnI5PTOgpHvYzoe4HCQajuFubkSFTeT23ALKu+Z843ASXH1EG+/SicSXP/LmF9g==
X-Received: by 2002:a37:c097:: with SMTP id v23mr8157746qkv.62.1551926768909;
        Wed, 06 Mar 2019 18:46:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqxth5xdi67Govi7kqCoGZVvBfBoupaN7UdjIa6h5e0cSzgqVz90LVeQDf+oBJAw1CLDeT+D
X-Received: by 2002:a37:c097:: with SMTP id v23mr8157720qkv.62.1551926768196;
        Wed, 06 Mar 2019 18:46:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551926768; cv=none;
        d=google.com; s=arc-20160816;
        b=QDlxkIY0NdwqXMO8doiLK1x/mZJik4tzxcg/y/KCxg74DGl8W3fWUPONtNIyukHoKQ
         FHwwpElXA4yhu+3udguL7pismt8znPoMJ8gs8qCWGRg9gu2T2lhxBXAavkHf1AN6RYkg
         WMnb69mnNks7X25lmim3fdzn/1fMbeQ+Omlsb3/xcmL4qdW37uC3hw/pzUfuV1q93R+r
         dImgooIarkiv8Q60VRHHJe/QdqFBa5hGPAYaZiP/TSfGODYN4jd2URdBMW2lttw11ZKJ
         ZaQzJWutUj4RhWRj4YudlrJMrku/NyGnP2/yJVQK7Kazf2TfzuA/9bORWoE6phTOQCy+
         Kftw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=V8y4Da7EC7/NkkBxiw9MiVHU1l5kq31Xn/NFenvOq/Q=;
        b=GEiiaEV1KQ7N5LD9PJNHqBIBqHlSR0pwhK2s+IbrgKQRkdMD82bJK57crQIFMd6Yl/
         p4xsLGQFXKeAYV0RSlLVT/uOO/SGtiQ2SSwIEtGUpjgWW/uQ67JH3MWeV75XE4xLLkJO
         lSsLVOJx4XqcYhNRhitwSLWE61oYaEmZPCwSu4tkZvet5yq/qzY9Ed2H4gAvTpwwfEyr
         thrOsxafHr6rqMTTpAs0LYO3FnyFpNctfSokOVYyutTNxCWkG2fhjG7G6gTV0AMs3co5
         AfZvPWSBQ65QvIzPSjrtOZ1psAuKZKOGkP0ziN7OIBID0ZNfcDVK0HDFdZ7cKBkoTDmt
         yl/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b22si2046164qvb.187.2019.03.06.18.46.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 18:46:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 65AF7C05090A;
	Thu,  7 Mar 2019 02:46:07 +0000 (UTC)
Received: from [10.72.12.83] (ovpn-12-83.pek2.redhat.com [10.72.12.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A0A7C1001DD9;
	Thu,  7 Mar 2019 02:45:59 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, aarcange@redhat.com
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
Date: Thu, 7 Mar 2019 10:45:57 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190306092837-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Thu, 07 Mar 2019 02:46:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/7 上午12:31, Michael S. Tsirkin wrote:
>> +static void vhost_set_vmap_dirty(struct vhost_vmap *used)
>> +{
>> +	int i;
>> +
>> +	for (i = 0; i < used->npages; i++)
>> +		set_page_dirty_lock(used->pages[i]);
> This seems to rely on page lock to mark page dirty.
>
> Could it happen that page writeback will check the
> page, find it clean, and then you mark it dirty and then
> invalidate callback is called?
>
>

Yes. But does this break anything? The page is still there, we just 
remove a kernel mapping to it.

Thanks


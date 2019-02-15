Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57D9DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:30:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B678206B7
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 09:30:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=linaro.org header.i=@linaro.org header.b="T7k/lFrP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B678206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linaro.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 949308E0002; Fri, 15 Feb 2019 04:29:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F9AD8E0001; Fri, 15 Feb 2019 04:29:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E7CD8E0002; Fri, 15 Feb 2019 04:29:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5DD8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 04:29:58 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id w12so3474830wru.20
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 01:29:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=OEnwGAiuFy8bBpFq9pPytLIcw+y/tAtIcUvB8liOjts=;
        b=RSCT1kvKZfZjWArDsKSbh69gY9h8F+vLuS5txgUTxu8rZW2L61PFdym+8Rw4JzdaCA
         COVRPAELvtFvkSHoZ7/wxee4OFbTGGrEwY/WP3ojGzIV1vf+cgsdAA/M6NmK38gzUC/d
         6ioiXFHzvgxYR3Mh0eJddw5imYOo+vDxC7jjMqftfWMlyeBJDs5CiwzYVcXd693w/zQP
         jKSLWhECe3mrD1F6Sz1pTE/LWQq3fXWBBFzzK/40uRdnvMzixF+BY9k0nW1/W/5ExOXL
         OpmybCbbm1OXQAqVGOErRvsrxTtgBG0i0sgVx04/SCL88p4zPvS8eyyrIEgf87Br6h6d
         K2JQ==
X-Gm-Message-State: AHQUAuY3zHVqbNajEkOiJKMWqakMdOeO8JuIFLWBJbyeWGbUpnVj8Jbg
	wXYGVFrz158wDs3dWnptOh5eik0EGiIDWE2DZA8gPCW7BDpgiVUpmdIbyTKwpml1OZxM1kZp9v3
	oIlvqlbJk3Y8YEXyH1LrAjnmHXhgv+fjl1zy0h4gIJetV/2Pt8IwyMZoDPBkxoyQLcixSjgoK7D
	gdYDbclScLLOY/4nqsEHcET+RfQgMlYYUBRA5QLYKkgM9PzjUNbbwjcroDVpT3WMwERQLszaP9K
	zPV5DN1BFvY80EoSd4/Bwq9UhLu7BziLHoVrYei33ju3bnS9+EtE0GCZbm5fmmQ5uDj5gvefV78
	TEB7QyGGXzvHF/Q+e5dpIR76h1zeZt15KnXl9SKI7yFLIMzIGhX5TLk5bvl0OpPwpl10mtlgOjD
	j
X-Received: by 2002:a1c:e911:: with SMTP id q17mr6277141wmc.31.1550222997665;
        Fri, 15 Feb 2019 01:29:57 -0800 (PST)
X-Received: by 2002:a1c:e911:: with SMTP id q17mr6277091wmc.31.1550222996730;
        Fri, 15 Feb 2019 01:29:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550222996; cv=none;
        d=google.com; s=arc-20160816;
        b=gP9UFh2Y4kGjrGZUZSpLFhoC4ttqgM/7wmHiQ5BJ0q7kbSSdDVtD16NsPICk/z0mY9
         rEbLb09OQAJANxEw61mwqTV+CYmuhYgGquE3hVJoKpwtVuSjm1SRMDR91IM0yBhSv1N9
         haR2oINd5LCakGfF7HEcZTQ7AKpP1sKhMreISEQ9BAw7aEw9vct86cfWXVxvRlsHg+CG
         MrlxnDND6Xqcc9hUDoAJvy+FEtbX4i6JQS/PH+K9fIYJlcHRHlYoZdomCYDnnxk9jaOc
         /+L0Fp+uMmxtoYsXqEu/Dxm0qyHqG358JDQUa9E1CKCx26HfxCAzqH7yQzDxc/t5bY4b
         RBrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=OEnwGAiuFy8bBpFq9pPytLIcw+y/tAtIcUvB8liOjts=;
        b=NZJFyMM5etjccw9sS2LbuxTh3zHz08Dpxam+ptB/mjCLh7KgMr2VvwFVbnaSApr/Cb
         1J9aIg8MiVRYnPJTbFRaenZJac8N/PX3OA0buqYQi52HvYy8SaN9g1zxzDqY35h+vmKA
         4C5pjPcLD+elnd5FezARgOh6s/T+IEsWtL1VjhO+W61GGA5FREd4UtCN1cQxwjq2sJjz
         JmCEjHyYXqYeX9UtmTB7NZOIE98sXJ5c/Q/qBRETWV6UFV4P3yTFuknvILOfJG/l2W5g
         B1UsqY2yjCcTlv5CMkftDW8ziTlju33CO/QO7JI6UifECFd3BuYUDTt5cgGK4SSDoANg
         D1OQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="T7k/lFrP";
       spf=pass (google.com: domain of srinivas.kandagatla@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=srinivas.kandagatla@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 201sor7957552wma.0.2019.02.15.01.29.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Feb 2019 01:29:56 -0800 (PST)
Received-SPF: pass (google.com: domain of srinivas.kandagatla@linaro.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linaro.org header.s=google header.b="T7k/lFrP";
       spf=pass (google.com: domain of srinivas.kandagatla@linaro.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=srinivas.kandagatla@linaro.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=linaro.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linaro.org; s=google;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=OEnwGAiuFy8bBpFq9pPytLIcw+y/tAtIcUvB8liOjts=;
        b=T7k/lFrPu08ytbc7nMtd+y3ezVlYviXSgH/GjkGUn8ZbRquqaQdjmFm0yKqLK1HJso
         SdHvl/ycFZQAfJ5XN9bbax9QmR8yYjcdiG88aV9AgIiLhk97I54ZtTo80vWURWpylmEv
         +TVQxf6PfR6ThGQ0f8Z4b6cDgvMRbm+qT6obC2Vu2DVyWVZvaYGDBrpu1Jrui00KWj/M
         jdvmy6jDhfcHKsTncdJ+lEyEahpUfEHOxdGxVSK4LpuLRaoOHyIN62WOBqLwV7dGWziI
         iVmnfYQze6Z0cKqQud7HWGtGwqrLp0zcfMq7O1VB+3gAGPqc35ly4nJwJy6w/Gd9DdB8
         bF9g==
X-Google-Smtp-Source: AHgI3IbOZP5dvaRZOj/GZU5acXwgT9dklZld6SBAYIpwzRq2os3Cuxm05yYg4C/Ia/IlOYDrdYCqyA==
X-Received: by 2002:a1c:c003:: with SMTP id q3mr2425904wmf.84.1550222996296;
        Fri, 15 Feb 2019 01:29:56 -0800 (PST)
Received: from [192.168.86.34] (cpc89974-aztw32-2-0-cust43.18-1.cable.virginm.net. [86.30.250.44])
        by smtp.googlemail.com with ESMTPSA id q8sm9089993wrr.9.2019.02.15.01.29.54
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 01:29:54 -0800 (PST)
Subject: Re: mmotm 2019-02-14-15-22 uploaded (drivers/misc/fastrpc.c)
To: Randy Dunlap <rdunlap@infradead.org>, akpm@linux-foundation.org,
 broonie@kernel.org, mhocko@suse.cz, sfr@canb.auug.org.au,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org
Cc: robh+dt@kernel.org, Arnd Bergmann <arnd@arndb.de>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <20190214232307.rIB08%akpm@linux-foundation.org>
 <44c1e917-bd56-cc51-8b65-0bcedfcd5f4a@infradead.org>
From: Srinivas Kandagatla <srinivas.kandagatla@linaro.org>
Message-ID: <619bd894-5849-1eab-b12b-da76d8d52c4c@linaro.org>
Date: Fri, 15 Feb 2019 09:29:54 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <44c1e917-bd56-cc51-8b65-0bcedfcd5f4a@infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for Reporting this Randy,
I will send a patch to fix this!

On 15/02/2019 03:20, Randy Dunlap wrote:
> On 2/14/19 3:23 PM, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2019-02-14-15-22 has been uploaded to
>>
>>     http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
>> more than once a week.
>>
>> You will need quilt to apply these patches to the latest Linus release (5.x
>> or 5.x-rcY).  The series file is in broken-out.tar.gz and is duplicated in
>> http://ozlabs.org/~akpm/mmotm/series
> 
> on x86_64:
> 
> when CONFIG_DMA_SHARED_BUFFER is not set:
> 
> ld: drivers/misc/fastrpc.o: in function `fastrpc_free_map':
> fastrpc.c:(.text+0xbe): undefined reference to `dma_buf_unmap_attachment'
> ld: fastrpc.c:(.text+0xcb): undefined reference to `dma_buf_detach'
> ld: fastrpc.c:(.text+0xd4): undefined reference to `dma_buf_put'
> ld: drivers/misc/fastrpc.o: in function `fastrpc_map_create':
> fastrpc.c:(.text+0xb2b): undefined reference to `dma_buf_get'
> ld: fastrpc.c:(.text+0xb47): undefined reference to `dma_buf_attach'
> ld: fastrpc.c:(.text+0xb61): undefined reference to `dma_buf_map_attachment'
> ld: fastrpc.c:(.text+0xc36): undefined reference to `dma_buf_put'
> ld: fastrpc.c:(.text+0xc48): undefined reference to `dma_buf_detach'
> ld: drivers/misc/fastrpc.o: in function `fastrpc_device_ioctl':
> fastrpc.c:(.text+0x1756): undefined reference to `dma_buf_get'
> ld: fastrpc.c:(.text+0x1776): undefined reference to `dma_buf_put'
> ld: fastrpc.c:(.text+0x1780): undefined reference to `dma_buf_put'
> ld: fastrpc.c:(.text+0x1abf): undefined reference to `dma_buf_export'
> ld: fastrpc.c:(.text+0x1ae7): undefined reference to `dma_buf_fd'
> ld: fastrpc.c:(.text+0x1cb5): undefined reference to `dma_buf_put'
> ld: fastrpc.c:(.text+0x1cca): undefined reference to `dma_buf_put'
> 
> 
> 
--srini


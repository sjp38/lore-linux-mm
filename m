Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96453C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 20:54:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 482372618D
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 20:54:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="H1VqQ8Mb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 482372618D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C87406B026A; Thu, 30 May 2019 16:54:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5E1B6B026B; Thu, 30 May 2019 16:54:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4CAC6B026D; Thu, 30 May 2019 16:54:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD9D6B026A
	for <linux-mm@kvack.org>; Thu, 30 May 2019 16:54:29 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id o98so3400096ota.11
        for <linux-mm@kvack.org>; Thu, 30 May 2019 13:54:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ODypozAerLNV/qGeHJPqtJFJozABAAaZHRXDF3WkeeE=;
        b=BO7eZJe1iLHcIWqKC4lxnjCreOsgwQIElbT083ou1Fis/mzPV+l/U8mxh1tsyb3v30
         VYuAookuN/6UvvfOX+MnWrQRM+aXWLtyzjMMEtGydcS70+dydE0pk41RWkOEatcACtdZ
         Xi+RL6qVmqa7Fz3fMVkdB39z4jyVmc854Xku3v2NvvKgD2Y8snk/T79a3hWDzXm5AaDf
         CGi90HvTFIkyGKbU1gAi817pMkdLinr8XpV54G2zL8GjejkDni8/BvDsgiU84hl0hnHk
         s+9pnF4RGmx9O65PLLtetF6lJdm4kur2vZ3RMzg2nlIxRnUSlhBzRUUcJ+5+vhRH7JD1
         FAAQ==
X-Gm-Message-State: APjAAAV2yhyio4VkDKRy8Vix9abzGWq8MX5V2PfPab6xSGyS2qKnFTVK
	vBijMqdz4QaxoqmtXdHdvbUlIN8mdQDaEkoJ9dYut4LsTbRd0uasF5n5ZtFdL7JLen6IW8H5ZdC
	kV4lIJsqNWlTu20pkvfWedJ5ECXkTR0hN0BZ1BIiFAgxyx0tsx+zz5nKjRrEoK5Xw0Q==
X-Received: by 2002:aca:5e43:: with SMTP id s64mr116925oib.152.1559249669218;
        Thu, 30 May 2019 13:54:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqbPO0qjFUTagbn5U6x/wV54Nv28yEoP104pf9+OdEXp2EpikLQeHJeObE50/BcKI8/FcT
X-Received: by 2002:aca:5e43:: with SMTP id s64mr116877oib.152.1559249668224;
        Thu, 30 May 2019 13:54:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559249668; cv=none;
        d=google.com; s=arc-20160816;
        b=aZTC4pcfZ+4DaE7v5UZPMGkOrP7PZQKE2e4QcKms5xy7l/0bc/ktySRqiBkAjRRAvr
         NIbDrCaJqTGxei1dXh0EdNrb1uYCgpdoVM1zRfTGCu77pQ01xK6tfZ7SGoqEs/1lELg1
         myC4IPfoJPGkiUSu0D6H5gi+tLEzvaH5l7ZWtKdy+kQWO/L66tWHbqqtk0+cLPcanlmW
         qN/Q57p+iC+FAQZ4/jyvCHeKM3Ioc3tUiT4FL9aP+QoHq7F7z1taqF0hNWu+Hrg1D87L
         VgUrVR2xOg2SuWYDZzRNvxUaaY2u7GXhahVMs3ZgtlHmBt/CnX9fY+S0WgAaqdBVI9w/
         8qmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:cc:references:to:subject
         :dkim-signature;
        bh=ODypozAerLNV/qGeHJPqtJFJozABAAaZHRXDF3WkeeE=;
        b=0qwAS9Zrjy5tOb+h4Oz8pcySaaWbn5GHB22JDbuL8KwKm1GkLK7wF9ULMFWjobDPDv
         ScMw0zB0uUHOzYFp9VS0Xla/gsPEDz5p8tAWLgSk8HXlqd9/hVfgFe87D+DN1nxjaxRQ
         0pNluc0k0cWWk8udyxEgBA5kgK3gX/Y/dt4vzuvwm5v7mFBBE2rbKpybJXPE5frcbIjU
         VjtV+3BnT0FNOJ2+wOy/b9h8K8fGao5NXKUws//q5TlLyU9oZ6KkQh+PzJu0iVVHzIKL
         G/N/JNwTQni2Ed+S149Aow+RWxGxxI2wNA569jrlwZj8SQF/hsAOBlMDaO09zbZwWsR2
         sV2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=H1VqQ8Mb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id z186si1778339oiz.28.2019.05.30.13.54.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 13:54:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=H1VqQ8Mb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4UKsBcM108403;
	Thu, 30 May 2019 20:54:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to :
 references : cc : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=ODypozAerLNV/qGeHJPqtJFJozABAAaZHRXDF3WkeeE=;
 b=H1VqQ8Mbp0VXzmkHQ4b5+kN0x7UMsTziL9j2TPr4OvwEe5RtZIrLNRWCBAzhPDrmvtY+
 LneSmuhyriW7u/fRnYl07QeEdAWpU9X2J6ZnqXAimhArpziTJa6LxS18sVe3SIcjFZly
 1lB8qnkhxFsp40rO2F2O6ix/gBh3o9xFTX5Qb9JvKeT6Ut/6zATvBAn1jj7OCtNH5cP/
 nZGwjLFPV0MViT9cUc7ylXDiMfNRbrh9iO+PKBgnegFkPpC8vhw3zQfeKSMl9aAc39D2
 HNWbf6jcazqGJkuIGdURnF3W841tAIFanqF+0omrr8820kRMMn3UnOWnTzokauspVqiK EQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2spw4ttnyh-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 20:54:11 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4UKs4aL156896;
	Thu, 30 May 2019 20:54:11 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3020.oracle.com with ESMTP id 2sr31w3qbq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 30 May 2019 20:54:10 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4UKs9TR011670;
	Thu, 30 May 2019 20:54:09 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 30 May 2019 13:54:08 -0700
Subject: Re: mmotm 2019-05-29-20-52 uploaded
To: akpm@linux-foundation.org, broonie@kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, linux-next@vger.kernel.org, mhocko@suse.cz,
        mm-commits@vger.kernel.org, sfr@canb.auug.org.au
References: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
Cc: Huang Ying <ying.huang@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fac5f029-ef20-282e-b0d2-2357589839e8@oracle.com>
Date: Thu, 30 May 2019 13:54:07 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190530035339.hJr4GziBa%akpm@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9273 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=703
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905300148
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9273 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=729 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905300148
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/29/19 8:53 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2019-05-29-20-52 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 

With this kernel, I seem to get many messages such as:

get_swap_device: Bad swap file entry 1400000000000001

It would seem to be related to commit 3e2c19f9bef7e
> * mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch

-- 
Mike Kravetz


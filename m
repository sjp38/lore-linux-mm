Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41721C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:01:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF0B120818
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 22:01:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="gaY26Ndi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF0B120818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87E008E0004; Wed, 27 Feb 2019 17:01:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 808E18E0001; Wed, 27 Feb 2019 17:01:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D20D8E0004; Wed, 27 Feb 2019 17:01:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F7BB8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 17:01:07 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d49so16784089qtd.15
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 14:01:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=LQ5rYxmcH3WAzFf0sRvQ3XlMmD9QOhCgoOKYt96kr/E=;
        b=bnMDkT3OKpgsbgx25Vt5Q1OkNT3PL7lOcEmUm9LSAV678T+hmVDLh+y051Y/90dYqm
         BX+hFYphsPyvb0xudVrKVEqA97jnvjEK1kYfnxPCyBnJ1CsMAcoSbRO8mnbv3sDB7zbv
         dHjcOkNtONSus8duHuBBubPv1fkyKM0ySCh1V4OPeNL754QJfbl2RkQOZJZPH1pHbxMD
         L/jPPNAfj+hNC4z3nRWzvBMe9rvFJwbQ4cbMPO0S4fe0XpKNiNRay89u+MlmTFqyWVP7
         NWQxVpPszNNqbon8YE3HkY+5L9Wiy24Pxs3W3Un9qHESeG0lb7AjAYIrJAO4NaaR/ZcK
         HvDA==
X-Gm-Message-State: APjAAAWgE/U2M1KjX1SB3of5/7QxuxcL3HFYp3X0SMYHReqCW715rvEP
	HXmwS5YrSUsLtt6wfTvLr946goipyU2YC02jBbTIEO7lw/+Fp3ZZCYl3Yld73YR70x2iXaKdPpo
	XF4OtMjzFYDkybtZEV7JWjE/nokdJoeBcPM6DbATUevpLAdRLIH+6+9xnlipcgEhX+A==
X-Received: by 2002:ac8:28f1:: with SMTP id j46mr3538683qtj.133.1551304866985;
        Wed, 27 Feb 2019 14:01:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbTZH5LZDY0UYdTZ67VnGxNkxlp94/9u0WrBaSj/i8Il2SQ50jhXkTuFQ74I6sxAbWYlfFJ
X-Received: by 2002:ac8:28f1:: with SMTP id j46mr3538623qtj.133.1551304866008;
        Wed, 27 Feb 2019 14:01:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551304866; cv=none;
        d=google.com; s=arc-20160816;
        b=dw6rvPSkZOLX5AF9j3/JiORUzKw7rkNaDvZ4iZmdDgU5jJDOlWUjIIlmtQ6dq0J/e7
         bl9bkWGHQsalGDwcmUH2C8DmKU+df1/1OfY8XYyrEQCVV9bhXe/+Eh5dmcZxZ2TTcQcx
         m16Q1OVKLT0uD2EzYx2NWllLZ60NSjPPVQlkgAnkZm44lJc6pJurIYf5/GiV/l7N39Yb
         9YVOQUkdgKvnK/sA4EJDsWy2VxaVKpc7hksQNEAFNbSRWEdHXyQoZnFFRtSDuTIPok02
         FAOoanKUdOJzX5ej0u8Hg/K1fvNG07Os1U3U2RA/xnhZpO/At5FGOJ9hYYIJMsBBxCLH
         IJ0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=LQ5rYxmcH3WAzFf0sRvQ3XlMmD9QOhCgoOKYt96kr/E=;
        b=kuJqkESocqb8N+4yQSKrIfFvNcF9+JahSr6MnvreJYPwJER5sKEiZs//MV9kH83D1G
         u3cHstQ9lGmOCTGuyxtwKXXwcMoEhrnVxezn9ne9Xkpadj1LttiPccHyTf6WI7q0A73z
         OdPpAl7Mtm6205YExV9/Scl6KvKTSjCLceGOF3SVe0c4uTIS4c86o3uyg5oZQeb95lcM
         ZVAGnVivU+5be1C77tPJj5mobNk4nF3BNwU4VpYJKaeDMDUHhXzgP+Ns00ffB9QRLO4f
         ORa4NHl/7RHP3GQs8Gwdnj7OgiuYR3bQU0Ep715On516ja70BRgXdgYtRm7frgrkA+0A
         gcvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=gaY26Ndi;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m4si1176644qvi.70.2019.02.27.14.01.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 14:01:05 -0800 (PST)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=gaY26Ndi;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1RLs1xM123838;
	Wed, 27 Feb 2019 22:01:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=LQ5rYxmcH3WAzFf0sRvQ3XlMmD9QOhCgoOKYt96kr/E=;
 b=gaY26NdiNElYQFqrnLKZRR0hM5RzzHN3XsCcgmOqE1GfdTdHthzQGn0kiwbqJBA/NPNZ
 pGBiumlOS0qcNZGTSA0B+lbkZ7KQYBRFR6EZhldlbBGVxcIbh7hS1onSFTty9IoAMVB2
 2Hb63htXFBAwEv4iVdXcmS3E41uYMtdciZZGiOAye8/IlT87DGqgHplrHUdvHed2j0O6
 XykeNh/y93s/uW8LMJgmSyNHoyCg+udUPpdVXX/tRxybkIl/7JfmGGARicvrJkKVpoyY
 LnubGmu58CiDnP1qWFTd+6EadHfOhKba9fq/64qGjClCPzk6d1AgeF8GfYbXX/F8jYns fw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qtupeds84-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 22:01:04 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1RM0wGE002947
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 27 Feb 2019 22:00:59 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1RM0w58026884;
	Wed, 27 Feb 2019 22:00:58 GMT
Received: from [192.168.1.164] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 27 Feb 2019 14:00:58 -0800
Subject: Re: [RFC PATCH] mm,memory_hotplug: Unlock 1GB-hugetlb on x86_64
To: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.com, david@redhat.com
References: <20190221094212.16906-1-osalvador@suse.de>
 <20190227215109.cpiaheyqs2qdbl7p@d104.suse.de>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <201cc8d8-953f-f198-bbfe-96470136db68@oracle.com>
Date: Wed, 27 Feb 2019 14:00:57 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190227215109.cpiaheyqs2qdbl7p@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9180 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902270143
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/27/19 1:51 PM, Oscar Salvador wrote:
> On Thu, Feb 21, 2019 at 10:42:12AM +0100, Oscar Salvador wrote:
>> [1] https://lore.kernel.org/patchwork/patch/998796/
>>
>> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> 
> Any further comments on this?
> I do have a "concern" I would like to sort out before dropping the RFC:
> 
> It is the fact that unless we have spare gigantic pages in other notes, the
> offlining operation will loop forever (until the customer cancels the operation).
> While I do not really like that, I do think that memory offlining should be done
> with some sanity, and the administrator should know in advance if the system is going
> to be able to keep up with the memory pressure, aka: make sure we got what we need in
> order to make the offlining operation to succeed.
> That translates to be sure that we have spare gigantic pages and other nodes
> can take them.
> 
> Given said that, another thing I thought about is that we could check if we have
> spare gigantic pages at has_unmovable_pages() time.
> Something like checking "h->free_huge_pages - h->resv_huge_pages > 0", and if it
> turns out that we do not have gigantic pages anywhere, just return as we have
> non-movable pages.

Of course, that check would be racy.  Even if there is an available gigantic
page at has_unmovable_pages() time there is no guarantee it will be there when
we want to allocate/use it.  But, you would at least catch 'most' cases of
looping forever.

> But I would rather not convulate has_unmovable_pages() with such checks and "trust"
> the administrator.

Agree
-- 
Mike Kravetz


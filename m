Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8C56C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:40:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 977712083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 18:40:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="C3RuE/4y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 977712083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 34A7E6B000A; Thu, 11 Apr 2019 14:40:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D3C06B0269; Thu, 11 Apr 2019 14:40:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 174EE6B026B; Thu, 11 Apr 2019 14:40:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE1D46B000A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:40:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id g1so4790253pfo.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:40:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GB8LfO77Jy6JgNbe7pmliFg2YECUcEkjiuvkWQ7pqHo=;
        b=ljTnH6HHcxg+gP2lXYEfjj1Y1+leYH32FWQd10474f/CbfksILKbPO+cOeMx/bqLXM
         W9XBZ9B7PKs+D6M4Ojz0mdy0nYC+SoNxGdwAA1/m5timnpm22u/1pivXE6qPECQDodXB
         6E5i443ihYFiiWOZ44D1l2iuJ850f/8kS7Si0H0I19K0mYWse9u0cVHp1PhO5Q+gr0fZ
         3zkut1oC6j41xHmgs724BqD7S191gbxG476ManjhLncMKsWZQ54FT6msbIVoCZqJQF5u
         F7s1GxbOTdjLz+1WNxovGkrrdU1rfJjYKx3fn2xkAXncUidwRsBQVzm455kbLChIwmAZ
         cf4g==
X-Gm-Message-State: APjAAAXLAFjdeSqEgrxxbhcijY/LqBcwLsYymeMnvZPPGvmjafq7vpQ2
	Azn1pXs4jUZc4HELodqDJLVfJXv3HSHOO4hLjT9NNe4VnPBuMQz+7+cOv7aQCPzihKn2SCrxaN4
	oe8YzQRDPp956FZrkYl3wP+AMqANbCqKumf6dqZ6Q7JBDRVBlR+u9ybYVoDsX5/bgIA==
X-Received: by 2002:a63:a04c:: with SMTP id u12mr49145566pgn.131.1555008015433;
        Thu, 11 Apr 2019 11:40:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx/OGn/asKyqpSeV48hV50Nw0nxly2XTZyW4oBWGrRNfHTDQuIbLwlWIA12Q74edBv2FCna
X-Received: by 2002:a63:a04c:: with SMTP id u12mr49145529pgn.131.1555008014825;
        Thu, 11 Apr 2019 11:40:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555008014; cv=none;
        d=google.com; s=arc-20160816;
        b=sHdhn0r4Hr+Ge+WOG2coQkDypuc7qi5qDn7OKmD5BES4DwftWb/sYQfdf7hBBqwpl5
         9m8GoSrlQP7z23ooGBBeHziM185isfa9Te4Wxf6IJ4EjfO1yAJdMG9mZ+Wt+JtySU28f
         ZumUfQwCrKcA+3pA5VORg7OrE3UQHLDRuPizKC++/BJJFcLQgJkOh3L3XH5qFLIlVh2W
         9xESkwE/9m4OMmj3abESGxx3r02sf96yB+Nu7jQ3Yrh6WleGXwDGpKusKlTuVk+/nxif
         Sh+Srrd7JvAYXV1HvTWS6QMC/OrjGuKZdFJAFNVOYNdL/k35yaQsWiZqxdEi0qPVGYie
         GQYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=GB8LfO77Jy6JgNbe7pmliFg2YECUcEkjiuvkWQ7pqHo=;
        b=OIk4uilqLUZJa7ixdxwIsim/S6s+gpN76HeKkjYDRcCBwSZtceGEOSqZh7iPDg5DFd
         N5TAZmGDEEeWhrGRGlD1mAaHvGKWJcXbsr0DbxDMOQly/L7QOhZTasea5/Is7VBfjlcw
         sf+s2SWoVC34pwMTG9YQf4XIMJdBlKnxpnXMitH1+DU2nPH3hBdTlTvQqTuEQsVQeXma
         ITaU5qLUXsb200ID1ZpmlIJ6jxjvQqwHF9y1zeYvVvsydRVQb7DjlSyI8D7HeSKO+KmR
         vJpb7otSikOZqe+fh+N6itRbgJ2JsIHXxYmooGrvXBjWbIyDOZvPYRVSeHr2EoK8FnJf
         C4fA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="C3RuE/4y";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k12si35845014pgi.107.2019.04.11.11.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 11:40:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="C3RuE/4y";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BIcft3103044;
	Thu, 11 Apr 2019 18:40:07 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=GB8LfO77Jy6JgNbe7pmliFg2YECUcEkjiuvkWQ7pqHo=;
 b=C3RuE/4yqybULo8qV1Vv7aydlTkpNoAfka9yhSfCHfvmWgjDsP0ilTAjnBJ+Ndm6CuBl
 lGZe7L47sq7tzdY3377JHsnBQQoDGDzZ3ZYkuUr3TCaK1UgxVaJVGoXk9tWrIUtns+k7
 Ur/QPvOZ1vyqtTuIcVl2u1Pd1QDxG0WmzO9w4zSqi/+Wjd2ZuMBPKYfwykto6ZIt8apS
 G5Bc4LL4tyqybrdB4Zu10vO94jjUigFpPhL9E6T0/QwA0yBqqhlYcgkYP11VQdZFbne0
 3HxQ3gF32+CI4WQVOKN7psF4TAyWzdpaQYaKZPRRSHGbz2cUfVjGe2kFTDq7ILYTIUMB VA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2rpmrqjku5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 18:40:06 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3BIdffI194833;
	Thu, 11 Apr 2019 18:40:06 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2rt9upsbwk-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Apr 2019 18:40:05 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x3BIe4fm013938;
	Thu, 11 Apr 2019 18:40:04 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Apr 2019 11:40:03 -0700
Subject: Re: [PATCH v2] hugetlbfs: fix protential null pointer dereference
To: Michal Hocko <mhocko@kernel.org>
Cc: Yufen Yu <yuyufen@huawei.com>, linux-mm@kvack.org,
        kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com
References: <20190411035318.32976-1-yuyufen@huawei.com>
 <20190411081900.GP10383@dhcp22.suse.cz>
 <b3287006-2d80-8ead-ea63-2047fc5ef602@oracle.com>
 <20190411182220.GD10383@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ce422d2b-dd9d-e878-750d-499b9a21c847@oracle.com>
Date: Thu, 11 Apr 2019 11:40:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411182220.GD10383@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904110124
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9224 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904110124
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/11/19 11:22 AM, Michal Hocko wrote:
> On Thu 11-04-19 09:52:45, Mike Kravetz wrote:
>> Or, do you think that is too much?
>> Ideally, that comment should have been added as part of 58b6e5e8f1ad
>> ("hugetlbfs: fix memory leak for resv_map") as it could cause one to wonder
>> if resv_map could be NULL.
> 
> I would much rather explain a comment explaining _when_ inode_resv_map
> might return NULL than add checks just to be sure.

You are right.  That would make more sense.  It has been a while since I
looked into that code and unfortunately I did not save notes.  I'll do some
research to come up with an appropriate explanation/comment.

-- 
Mike Kravetz


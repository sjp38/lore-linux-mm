Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04801C04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 04:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84A74217F5
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 04:33:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="3MoHNACh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84A74217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E53746B0003; Fri, 10 May 2019 00:33:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E04186B0006; Fri, 10 May 2019 00:33:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCB776B0007; Fri, 10 May 2019 00:33:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id A86936B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 00:33:50 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id t204so1908022vkd.16
        for <linux-mm@kvack.org>; Thu, 09 May 2019 21:33:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=DnWxQah1Do/p8EcIEEk2BiuTUT59Z4lUEvulq0K5mhc=;
        b=k2TwejHGMBGayIFXsATwD5Acr8iSvI3x1158o7jZh2npOvLe6VJbxz5UNu739sDkMd
         +A4xL6gmz7HZ/KqUr1xvJTbRZU2VdqZ0QVKtgeTn9bG7gyf2DguSBWuOxTEy+oItF90x
         PW5vpBHdFMdU0nuaZoGwIMMy2q4bIBGz+S6YK0KLnt+VvHn9HbrDKEvAkn3dpIxFwFcZ
         CqANC1FEWObyS0p4BE3w1GSWB9WStpfvmpSOJpSjrROvvlxH414xUW3/QnUOr2RrjQim
         d8qJs60q7WdQfBfVwev+yKDVG0ZezAYHAt+HgZ999Aq6nQyd0nkjsBUunP+Wx1z39ty8
         n1Hw==
X-Gm-Message-State: APjAAAUE9xcqn28wGlK3XM5ve2x/7i6qEqCN+acmUQlKsTGEsmyvCL4E
	+Dg7/sfOvZ7zILfUNqMAl1EIgdIqNMxyY4isWhTFCoYmRe6QB7kJXuT6OJm9Pie4oYmnif83EP/
	ktxsI/O/M5HhKc4tM4pG53ZvaD83gmaFEdSkSQ8jTPQuTEsvhqaTwvQnYt7wvPwg53g==
X-Received: by 2002:a1f:302:: with SMTP id 2mr4144802vkd.90.1557462830299;
        Thu, 09 May 2019 21:33:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqygDTbGM7a/VUB2wpoY6bEhEdEsh+rrCwtp43F9sDi7QDI5Ar2OikaViL+/TgJ/S+51Fvod
X-Received: by 2002:a1f:302:: with SMTP id 2mr4144757vkd.90.1557462829214;
        Thu, 09 May 2019 21:33:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557462829; cv=none;
        d=google.com; s=arc-20160816;
        b=bT3ppslMooMrE/YNz2ITiV7JcNLUXofK3INcHvu0r/jFWglTLVE7UHMlRnqtEzjksS
         SpCN49G/UMUY+DM+6L+J7VFt8enNUxApVIe4hdBADSKe2NrsHKSwe+iP1j2aigBc4U9G
         I4J5wl+OQitNfUprg/PhTntKRhBwhuGaa6364DQMLJTcYEmRbwL5L3NJd0FBBh+l2ncb
         fw0uMalwi8mo95W3maSnrcKC7luikApp00xavivM+9nw+5TKcvIyKu6VTd1QgMc+DOM1
         7EJhMOYon0/n/a4XuK5w+FvXohOS3tpzSG7NFmfI/TgzdqHTHaZCD3mu+fuiFr76ru+s
         1oMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=DnWxQah1Do/p8EcIEEk2BiuTUT59Z4lUEvulq0K5mhc=;
        b=m6POHyJilHFT5MH842SS/lOL2I+NjOkV7H3eEUjc8G+f8Z/NSZb5aWvlRf+JcdIwaz
         g9oFlsVJvxome2f+rsc0ByXQbcISzibAkuvBW98l2rq2s2qcmn/c63tuBRUHHx7vlOC4
         0WYOWgKzqVHbAtl6Vu5Flo2ZgDKxLebkHEHlQKqgi4yXVyLqKPBCx0QcEkWGM6jEC/mo
         oJl6b1X9jgdY9dNqW4QLBMFDZwQfW1q67e0CpvMWvF6L49x6nxO6L3xBSSKHR5zchseM
         YEj8X1vvi5K0tQLZil2VPmFKZzaxGegSLY4cODMUCOd3D9iYHWQH9icbBjATuotIrE+P
         WV3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3MoHNACh;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w13si722343vsk.407.2019.05.09.21.33.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 21:33:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=3MoHNACh;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4A4XiQJ043797;
	Fri, 10 May 2019 04:33:44 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=DnWxQah1Do/p8EcIEEk2BiuTUT59Z4lUEvulq0K5mhc=;
 b=3MoHNAChqFlsCkP77/nGN+VS1G0RkB6PQoQS+kDQ/kOn4FJ4PHSL8ImWCPRF0TZUaxZN
 BximiYmSacqyiPejbpmU9fUjvyt0TDSdFtiKVZgoiqrWd3SyyNif8aLmiKUbqVhgrTL5
 Ir4CSeL1kwItQL2RMBT/ymr9LsVxE0h8H22Yx0+Fx9YJgn/OZaAbz4d5dUN3+7dyDD0Y
 ziU2h8VCQWJxM4zPLwd8FeQjAlR/Q3UO+iGbOvuJM1OBn45YxIGv2SCTarTje1af+jxc
 eUQJUZJVJXDKK8TmWKfSRTqb9CMphOfxsAIep+8Ebvi8rT4suGjQdOH2H+60gY0JZIPq 5w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2s94bgep2c-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 04:33:43 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4A4XLbN157217;
	Fri, 10 May 2019 04:33:43 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2schw0733d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 10 May 2019 04:33:42 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4A4XbSt014833;
	Fri, 10 May 2019 04:33:37 GMT
Received: from dhcp-10-65-129-1.vpn.oracle.com (/10.65.129.1)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 10 May 2019 04:33:36 +0000
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <87tve3j9jf.fsf@yhuang-dev.intel.com>
Date: Thu, 9 May 2019 22:33:35 -0600
Cc: Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org, mhocko@suse.com,
        mgorman@techsingularity.net, kirill.shutemov@linux.intel.com,
        hughd@google.com, akpm@linux-foundation.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <640160C2-4579-45FC-AABB-B60185A2348D@oracle.com>
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
 <1fb73973-f409-1411-423b-c48895d3dde8@linux.alibaba.com>
 <87tve3j9jf.fsf@yhuang-dev.intel.com>
To: "Huang, Ying" <ying.huang@intel.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=3 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=582
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905100032
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=3 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=617 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905100032
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On May 9, 2019, at 9:03 PM, Huang, Ying <ying.huang@intel.com> wrote:
> 
> Yang Shi <yang.shi@linux.alibaba.com> writes:
> 
>> On 5/9/19 7:12 PM, Huang, Ying wrote:
>>> 
>>> How about to change this to
>>> 
>>> 
>>>         nr_reclaimed += hpage_nr_pages(page);
>> 
>> Either is fine to me. Is this faster than "1 << compound_order(page)"?
> 
> I think the readability is a little better.  And this will become
> 
>        nr_reclaimed += 1
> 
> if CONFIG_TRANSPARENT_HUAGEPAGE is disabled.

I find this more legible and self documenting, and it avoids the bit shift
operation completely on the majority of systems where THP is not configured.



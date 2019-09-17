Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A05BFC4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:06:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5818620862
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:06:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="D6Gt/2a6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5818620862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE7936B0005; Tue, 17 Sep 2019 17:06:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C98BB6B0006; Tue, 17 Sep 2019 17:06:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAD026B0007; Tue, 17 Sep 2019 17:06:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0160.hostedemail.com [216.40.44.160])
	by kanga.kvack.org (Postfix) with ESMTP id 971E46B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:06:57 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 4000F55F9A
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:06:57 +0000 (UTC)
X-FDA: 75945647274.29.bead96_3ca7fd87a9f2d
X-HE-Tag: bead96_3ca7fd87a9f2d
X-Filterd-Recvd-Size: 5869
Received: from aserp2120.oracle.com (aserp2120.oracle.com [141.146.126.78])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:06:56 +0000 (UTC)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8HL3tkM027491;
	Tue, 17 Sep 2019 21:06:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=DSHRnDjgTxLe+YR6luYam5tlh7HeP3ajnJpu1J2/rgs=;
 b=D6Gt/2a6dGY7BMUmcVzQhFQdUY5Bt+r5f4KAHruRXy1bJxbZ5jRfPgdZf+89ICxt5eHe
 ZdQuSVPVwwQPvdJW3/Gcu+jRw82fUiqgoEuLZB+rEKkJZ6kjgayPkJxeh25W8QAXr1R/
 piKypmQ/O2v9HEN+LcUHRvLmOCcMWKj9dWTSouhVjKmx+P7/UVDh2AnpbPKEXduwOud0
 4eGHkbdBJPmzBinlFy4NS5lGU25meoOZUMGZUekM3Rffk5fLgKIeYlSpP0mEYYhqPpAR
 0vBtRh4Du20APDQWyf01KDkmDg+cmO1/bf22z+TnFL/eTDyck+lKwtX+gVLdbjMWMoJy Ww== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2v0r5ph4fn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 17 Sep 2019 21:06:52 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x8HL3okW176167;
	Tue, 17 Sep 2019 21:06:52 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2v2tmtbjk4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 17 Sep 2019 21:06:52 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x8HL6pPh027850;
	Tue, 17 Sep 2019 21:06:51 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 17 Sep 2019 14:06:51 -0700
Subject: Re: -Wsizeof-array-div in mm/hugetlb.c
To: Nathan Chancellor <natechancellor@gmail.com>,
        Davidlohr Bueso <dave@stgolabs.net>
Cc: Nick Desaulniers <ndesaulniers@google.com>,
        Ilie Halip <ilie.halip@gmail.com>,
        David Bolvansky <david.bolvansky@gmail.com>, linux-mm@kvack.org,
        clang-built-linux@googlegroups.com
References: <20190917073444.GA14505@archlinux-threadripper>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <fc341ec3-65c7-ee49-eb03-9b069a8170b2@oracle.com>
Date: Tue, 17 Sep 2019 14:06:50 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190917073444.GA14505@archlinux-threadripper>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9383 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1908290000 definitions=main-1909170195
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9383 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1908290000
 definitions=main-1909170195
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 9/17/19 12:34 AM, Nathan Chancellor wrote:
> Hi all,
> 
> Clang recently added a new diagnostic in r371605, -Wsizeof-array-div,
> that tries to warn when sizeof(X) / sizeof(Y) does not compute the
> number of elements in an array X (i.e., sizeof(Y) is wrong). See that
> commit for more details:
> 
> https://github.com/llvm/llvm-project/commit/3240ad4ced0d3223149b72a4fc2a4d9b67589427
> 
> There is a warning in mm/hugetlb.c in hugetlb_fault_mutex_hash:
> 
> mm/hugetlb.c:4055:40: warning: expression does not compute the number of
> elements in this array; element type is 'unsigned long', not 'u32' (aka
> 'unsigned int') [-Wsizeof-array-div]
>         hash = jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
>                                           ~~~ ^
> mm/hugetlb.c:4049:16: note: array 'key' declared here
>         unsigned long key[2];
>                       ^
> 1 warning generated.
> 
> Should this warning be silenced? What is the reasoning behind having key
> be an array of unsigned longs but representing it as an array of u32s?

Well, the second argument to jhash2 is "the number of u32's in the key".
This is the reason for the sizeof(key)/sizeof(u32) calculation.  It certainly
is not trying to calculate the number of elements in the array as suggested by
the warning.

> Would it be better to avoid the cast and have it just be an array of
> u32s directly?

I did not write this code, but it is much easier to do the assignments (below)
to build the key if the array is unsigned long as opposed to u32.

struct address_space *mapping;
pgoff_t idx;
unsigned long key[2];

        key[0] = (unsigned long) mapping;
        key[1] = idx;

> u32s directly? I am not familiar with this code so I may be naive for
> asking such questions but we'd like to get these warnings cleaned up so
> that this warning can be useful down the road.

I suppose it would be possible to change 'key' to be something else besides
an array (such as struct or union) to eliminate the warning.  But, I would
prefer to have some type of directive to indicate the code is ok as is.  It
is not trying to calculate the number of elements in the array as suspected
by the clang diagnostic.

-- 
Mike Kravetz


Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A2A2C3A59F
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 09:00:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 31F0C2077C
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 09:00:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 31F0C2077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87D036B0007; Sat, 17 Aug 2019 05:00:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82D586B000A; Sat, 17 Aug 2019 05:00:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71BC16B000C; Sat, 17 Aug 2019 05:00:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0181.hostedemail.com [216.40.44.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1176B0007
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 05:00:34 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id EA0FB1E098
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 09:00:33 +0000 (UTC)
X-FDA: 75831323946.29.group51_3f143f5bd0b14
X-HE-Tag: group51_3f143f5bd0b14
X-Filterd-Recvd-Size: 4417
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com [148.163.156.1])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 09:00:33 +0000 (UTC)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7H8v0Yb134101
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 05:00:32 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2uecw4ahyw-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 05:00:31 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Sat, 17 Aug 2019 10:00:29 +0100
Received: from b06cxnps3074.portsmouth.uk.ibm.com (9.149.109.194)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Sat, 17 Aug 2019 10:00:26 +0100
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7H90Pst49807532
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 17 Aug 2019 09:00:25 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 282265206C;
	Sat, 17 Aug 2019 09:00:25 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.148])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTPS id 2AA2C52050;
	Sat, 17 Aug 2019 09:00:24 +0000 (GMT)
Date: Sat, 17 Aug 2019 12:00:22 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: Zhaoyang Huang <huangzhaoyang@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Zhaoyang Huang <zhaoyang.huang@unisoc.com>,
        Russell King <linux@armlinux.org.uk>, Rob Herring <robh@kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Doug Berger <opendmb@gmail.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] arch : arm : add a criteria for pfn_valid
References: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1566010813-27219-1-git-send-email-huangzhaoyang@gmail.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19081709-0008-0000-0000-0000030A0077
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19081709-0009-0000-0000-00004A281F4C
Message-Id: <20190817090021.GA10627@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-17_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908170099
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 17, 2019 at 11:00:13AM +0800, Zhaoyang Huang wrote:
> From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> 
> pfn_valid can be wrong while the MSB of physical address be trimed as pfn
> larger than the max_pfn.

How the overflow of __pfn_to_phys() is related to max_pfn?
Where is the guarantee that __pfn_to_phys(max_pfn) won't overflow?
 
> Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> ---
>  arch/arm/mm/init.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> index c2daabb..9c4d938 100644
> --- a/arch/arm/mm/init.c
> +++ b/arch/arm/mm/init.c
> @@ -177,7 +177,8 @@ static void __init zone_sizes_init(unsigned long min, unsigned long max_low,
>  #ifdef CONFIG_HAVE_ARCH_PFN_VALID
>  int pfn_valid(unsigned long pfn)
>  {
> -	return memblock_is_map_memory(__pfn_to_phys(pfn));
> +	return (pfn > max_pfn) ?
> +		false : memblock_is_map_memory(__pfn_to_phys(pfn));
>  }
>  EXPORT_SYMBOL(pfn_valid);
>  #endif
> -- 
> 1.9.1
> 

-- 
Sincerely yours,
Mike.



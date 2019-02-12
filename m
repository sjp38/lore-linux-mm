Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA642C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:19:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80120218B0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 10:19:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80120218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E44D8E0014; Tue, 12 Feb 2019 05:19:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 094B98E0012; Tue, 12 Feb 2019 05:19:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9DC78E0014; Tue, 12 Feb 2019 05:19:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id B93C08E0012
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:19:56 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id k15so2107450otn.18
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 02:19:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=S3ubpKDDNquhJgcasaCdX8dYPklFZlJRDxG6OMhF+iY=;
        b=nd/QU/XQO5gsqxS+Q61YuIV2YbbWdil+CrXUsfy/SWihtzAFESyhzsj1jyIdtfix0X
         ROs8TQZclkyTzwbe4mS0w3LciEcHph4joaGrIDDtJi+f8jrHuiOnrRowX4Z00Aft160O
         pShnh9HffhWKFpw+yLSQhjCd07NdfjYk91rLzxYBt0NvMTpTmSucFpICTzGmIc7B2CMf
         T3r9DV2fpks9mTNWaCXz52aUZeQH06a9pD5G5sptu5bcwVgZPAlTZ3DOBD32dgEsEeoV
         fEc3yTtkArXtBKjvYwbAagvMIjRdGSjySmgaSGux7egVthEu43OI/oYW+YdTULNoNe54
         rM8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuaDGag7UvjDEe7emHIdT15LLoljKkRXEKe/Nl7+hF5rqkYwpZIg
	Nw5daIWeG+ALpDJkHvkWT+GJB+o7npERzmjO9JC+goqN1UGAYeRZWgOh5rQTGPHjQ7mf2AzHy5J
	bKEWrGVOr+oRs7u3sABTYtdsWTtnoIpPiWifNiZe4ZhXrX6jCSXyPi7RLEhK9ig6BAQ==
X-Received: by 2002:a9d:760d:: with SMTP id k13mr3119284otl.100.1549966796527;
        Tue, 12 Feb 2019 02:19:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbQZp0TCZ05+377tRInTUJNytJd+68OpLaIZ4SsrOJUHj/IKV8ZC3Vo1vpcwfMoQLVJr5cK
X-Received: by 2002:a9d:760d:: with SMTP id k13mr3119252otl.100.1549966795922;
        Tue, 12 Feb 2019 02:19:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549966795; cv=none;
        d=google.com; s=arc-20160816;
        b=DrsSVE52ZpA6lmp5JsYgewZtzgjDMUzEZQPJluY0/6R0cBlmmNVKjiDDHSUfrvEtu3
         p/97lD7uCE4sSI0+jOVd8u1hhQkVlCrkOn2jVDXzKhiDM69TmGdYeUy8MNoaO2Iz0Yap
         djj4Z9JuqvDLbYzPkMovtDSFq3eKWT8guUn8KxlcS1/oT4rtDEu5grUGiZ+OsKOvXDqr
         Rm3A8KXniAo2P34pKIgUCBYOpxuaAFH9uKumuM0Xyiqz30YdW6a0kCmHK5LdINgPN8mq
         5CxdEc/OASJDHHcnFD9gtmnShetvnEZv6PMHbWtD/dpI/zqtslsiY3yZZDa/vdwPD1Up
         cP0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=S3ubpKDDNquhJgcasaCdX8dYPklFZlJRDxG6OMhF+iY=;
        b=YAFd+l1J9tstK6radtWexH/BHRu/m7RfbgPIE5IgnAWzdTWAU8MEuJom8TT1QDCUns
         3BNeJx3NCCG0ZP0VZBGOMWVXW1iS8kOxMZpI9PI2wZeyjAsjAq3v6u1TFdaZhVt2bn5F
         d7cZOkiL8Z7N5xCGpfhkHn/Jzo/WxbsBxgPwhmt49SSNc6vl7FnSmOyhJ3D7KQp5npNY
         2CeqvtT4hunb2SeGfbJyf0NI4z5SHKGefs72OA9fP3oGkUB6B0z3nm2KxsXEXrYWEtZb
         CHdtLDp903CeV4STitK3Cf7eOSF2bLADpGLpd3U72J/HUMgkE8V0dEw9OVQE0o/v+trd
         WK1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j13si2516728oiw.159.2019.02.12.02.19.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 02:19:55 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1CAJmPJ096398
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:19:54 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2qksxupa23-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 05:19:54 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 12 Feb 2019 10:19:51 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Feb 2019 10:19:47 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1CAJk1Q55377984
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 12 Feb 2019 10:19:46 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 55C9311C058;
	Tue, 12 Feb 2019 10:19:46 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 28A8A11C050;
	Tue, 12 Feb 2019 10:19:45 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.59.139])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Tue, 12 Feb 2019 10:19:45 +0000 (GMT)
Date: Tue, 12 Feb 2019 12:19:43 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Pingfan Liu <kernelfans@gmail.com>,
        Dave Hansen <dave.hansen@intel.com>,
        Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>,
        linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
References: <20190212095343.23315-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190212095343.23315-1-mhocko@kernel.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021210-0016-0000-0000-0000025576C3
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021210-0017-0000-0000-000032AF976F
Message-Id: <20190212101942.GA20902@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-12_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=648 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902120076
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 10:53:41AM +0100, Michal Hocko wrote:
> Hi,
> this has been posted as an RFC previously [1]. There didn't seem to be
> any objections so I am reposting this for inclusion. I have added a
> debugging patch which prints the zonelist setup for each numa node
> for an easier debugging of a broken zonelist setup.
> 
> [1] http://lkml.kernel.org/r/20190114082416.30939-1-mhocko@kernel.org

FWIW, 

Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>

for the series. 


-- 
Sincerely yours,
Mike.


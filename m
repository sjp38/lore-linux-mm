Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1C794C282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:57:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C602C20989
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:57:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="JqGGf6wr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C602C20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BBD98E0002; Wed, 30 Jan 2019 20:57:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66A0E8E0001; Wed, 30 Jan 2019 20:57:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5813B8E0002; Wed, 30 Jan 2019 20:57:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9598E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:57:06 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id c71so1672289qke.18
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:57:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=v65NJDP7dm6t2bHr+b2eIYa/xPxAPmHtLH6aialfpaA=;
        b=b1aZBWnr/acp2cGZ+yHsYl9HqoJyOB7BBJ+burNN8i+Z+fG8VkRJeNhvpJNUVyhhmm
         mJSfGJukYtimaOkDyWcvorzJI21akzhtj/lXuR/OdoKHeswAeppsJY3I8a3qfutBXDn5
         W4FlfISWrKFmnF1oUnEy4anCPO0e5AioyPQaLV8n1MpUZMQD3CTwsDve3mLm566d/8Ku
         VG5ESel6OKYPf4Qlmgp1yDIqpiE120q136XxEOe9JtZtgP7LunZQuvn06liqQGJ7iPW3
         1G6HepJE/ra3G2cGOpC8NWgrZDysc3V+Fu4E5T3IMUHuBauBGAMXZOX/5o3wRmAb1jca
         4oxA==
X-Gm-Message-State: AJcUukfBckQNFq61uCCVoIVt7eaZWHKyYC3/64aro98LYCtyhpvSc7nL
	Gq6cZ5qYYuH1KVS89jotNstljxMtjceToLcG/YweUleKb4YS+cdvmWEaWma9LDSb/5rQVFxzaAN
	NY2IF9oM5EOGuC1Dn8F2nRQkKguNQxIcV3i68MEIgDLkmZ6ksGonIeQyw6GiMraU5Vg==
X-Received: by 2002:ae9:dec5:: with SMTP id s188mr29519034qkf.127.1548899825954;
        Wed, 30 Jan 2019 17:57:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6BhgimYTCJNT5H0wdJMvTiY5LZP6o492xnOjH90+F9gijWg4gETPwGXq3Nb16KLxP+jC0J
X-Received: by 2002:ae9:dec5:: with SMTP id s188mr29519019qkf.127.1548899825509;
        Wed, 30 Jan 2019 17:57:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548899825; cv=none;
        d=google.com; s=arc-20160816;
        b=yE8gc+DsuvPCzcPKZHr7MgGnQH7wjnNU9jqGEiMAIzUgnx3jgCxTwTo0glQhrrBqWh
         OoEou7t7la2Kvgp9/echBE1d79UpjsPstVYanq2rrObm+0aHFQJXpIrWTl55SgT2/FEk
         BVmINk7yQqEN05sLXcwNnwA+qXwuxAwVFiffobuOqdd1ccvbU6669IGKLgYlaSDKaWyk
         aanuzHmYLClYlnllSPAhmK1M/9UKAO+kV3dE3Kcj9psGqIjFH+ezzYooXb+q3IFhBTB5
         ZodEBpQPTX/i9wBBHSuVvqkLCe7C5iYujzeEIhaXVwWWC0JAuw6TpW81KGRjzfeSM9eD
         rYhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v65NJDP7dm6t2bHr+b2eIYa/xPxAPmHtLH6aialfpaA=;
        b=wVxsVWKcMIL7REAo5EfFV0wRdnsdwHA1YGBl1IxbV9YeqFHZhOWCnjl0tk5Uwgy7nd
         /wNQi3f9bbdsu4uaGegAMdkiZGG7OIkGAJNEVHiBs9TIDKIZG9ylBGqNv2BMgbgxIF8r
         TutJcO0ynzFnO/HUBluFz5QdksPlJYsI7M1EV2KScDmU/dcXghZuZkN3sbu+ByztQKmh
         e4f8OzbGag9svs/Dx1VVdnUs/QVcBm3CC2IoHmocgba+QrZzb4qR6fSkpXVuxRR/OZSh
         YIgvPydaYvWnpVojfAj2e6D+0xt4lHF/ZJtrpMjVmea0eiF02n+O9pRSIrIOaByLOwvE
         Jesw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JqGGf6wr;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d56si2241805qtb.34.2019.01.30.17.57.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 17:57:05 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=JqGGf6wr;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0V1rX77046476;
	Thu, 31 Jan 2019 01:55:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=v65NJDP7dm6t2bHr+b2eIYa/xPxAPmHtLH6aialfpaA=;
 b=JqGGf6wrRwOAvgKJx+0CFcIXoDOis+tXKXfDR9HdLeBV68Fx+TUkLVXejrCg2FC4jg8o
 tt76nZVgx3R8cKKlNEFjSbf4Pj6FgZ9mEMGjuPJCUkYi+aoCGML+wS4IiNRj04AnlQY0
 hDE++TjMB5VEdUQb3h4CeOjiJBVrymX4T4IF2LmQ3Sxq0V7zPWHAL5VBT1Ag0IAhTUc/
 DPiL54EhNOOoPcZXX6EWuyitpOqDnh9xYasv0kynvMUjC9+oqTSjEZffZr4A5tqTiA5E
 PB7SIBIwdsqKno2DiDlMeX/DdORbngYacHKJcidiIsScP1KsIkKQYprOeEdjCO7IiyPh iA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2q8eyunwqu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 01:55:52 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0V1tkNk002989
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 01:55:46 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0V1tjCi026455;
	Thu, 31 Jan 2019 01:55:45 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 17:55:44 -0800
Date: Wed, 30 Jan 2019 20:55:57 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
        andrea.parri@amarulasolutions.com, shli@kernel.org,
        ying.huang@intel.com, dave.hansen@linux.intel.com,
        sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
        ak@linux.intel.com, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
        stern@rowland.harvard.edu, peterz@infradead.org, will.deacon@arm.com
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-ID: <20190131015557.lxxr2m47bsylzc3q@ca-dmjordan1.us.oracle.com>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
 <20190130072846.GA2010@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190130072846.GA2010@kadam>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=919 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310013
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:28:46AM +0300, Dan Carpenter wrote:
> On Mon, Jan 14, 2019 at 07:23:05PM -0500, Daniel Jordan wrote:
> > Probably no need for stable, this is all theoretical.
> 
> The NULL dereference part is not theoretical.  It require CAP_SYS_ADMIN
> so it's not a huge deal, but you could trigger it from snapshot_ioctl()
> with SNAPSHOT_ALLOC_SWAP_PAGE.

Ok, I'll amend the changelog for v2.


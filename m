Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19F35C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 10:29:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BAB78214DA
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 10:29:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BAB78214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2B7638E0003; Mon, 18 Feb 2019 05:29:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2666A8E0002; Mon, 18 Feb 2019 05:29:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 12F018E0003; Mon, 18 Feb 2019 05:29:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF1AD8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:29:40 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id y31so16517818qty.9
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 02:29:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:references:mime-version:content-disposition:in-reply-to
         :user-agent:message-id;
        bh=j9GE4pe0PP93FBq78MGaBMKwU5DddFSd6gUYB3CmTtA=;
        b=LrOTIx5IWWIrMBye6QGqQAEG+hisJQn2fCvw7ujLo5DeiwlxOA4z5Abjc6/zDdHq83
         S9H1aWn1o+f1BT1kM4CgKaU/wXhE5PZEFh8a27Fc0hSLrhi8Bj0rhfy+23Ogf8GVN6K0
         Cut/KfOU1NIXl5mgt4fCVt1/FWSANCNYpC3zUng1VrJhoLmFUMI3L54vVoAdCDt1ohK2
         60T0qEBGoR2zahvnnLLnl1gBVSbxGVMvc2AeWRjCNcXS0o8CwY/S0gPTF/ePDpHCrPJ7
         tDqoM6wZ8hzveGOUH2AL9zkffw3uU6PfdMdpihwfCe1vFq4OIOmfu/LFqAaoIMVRNYrF
         HCPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: AHQUAuZpVXwjxbm+29LqY6j4DLXw0046j/IF7JI+zX5b/eIkVNRWGpoJ
	Chlo3fWbH6zWW1839gOO928jdSeoiwfx72hpwiF34ydxmyoPIrccPi9BSD4uoN4VD1JMDrV8zYu
	EO4YP737jnLkE+HhE/jMXwVo3oyICf6y0vZt8xI51e9FyYb96B5xx4qGZEFPkpDg4CA==
X-Received: by 2002:a37:6a42:: with SMTP id f63mr16165348qkc.224.1550485780633;
        Mon, 18 Feb 2019 02:29:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZpNwusqX6NYyqQ3Z681I2z1mlV8qoKZYcAHtE40Hr3miReUJUfqlV3u8iNtEJ3yGwlkEoT
X-Received: by 2002:a37:6a42:: with SMTP id f63mr16165316qkc.224.1550485780033;
        Mon, 18 Feb 2019 02:29:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550485780; cv=none;
        d=google.com; s=arc-20160816;
        b=F8RPv5p9MBH4ttKoVQj0XhvKFPif8KmRf+q6/p9fSu9Lsz3jKLlR6Iok2RtyNpRpMM
         JGgGj6cffgen6o5Yv1+mTSm0mr4hMlzEBBmy3a4/y6XE1/AY3pjSwme7bDGI7hdgWr/B
         QnJzM5pP6nLMsL3V0Nr9hppK6lPZkqYV47j93rkWaKEAyB3XOGwpF/W2PeI9E0yu0+yr
         pvbChm90u1LXZ7MDBAg/HCrXrNFE9DKBXmLlgO7TnBYzwwMkNK+xEBMXQn/M3hR7k/ZH
         2oM6lSQty0n5gYf1xyTlHFj60Qtcw3G8I5Jhqfac7W66dsohzq23s3buar/TRGheCC7e
         ERgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:user-agent:in-reply-to:content-disposition:mime-version
         :references:subject:cc:to:from:date;
        bh=j9GE4pe0PP93FBq78MGaBMKwU5DddFSd6gUYB3CmTtA=;
        b=rMUdKo2lxpnjwJUUgJYGSPBB6jXNSZjmVZDihaehXANVHgjypGRVjVhWJohfCcSmlC
         LQp+Ay1Z8EujkiMGvJkyLhJhuZO8O9FY5T4YornnxwxyNJJy3/5WCziZ8GWjZaicOePr
         uwfCoGCkFn96sC6sTYFW4HCWlerTZGNZ/xSP27PUpiemFxcwSDJug0i4xwTHfHYylBLC
         KxneSVrpBfkZVnUMW+WbJF+cTbue49P6egyvs1FcRrpmGiK0i5d1PwR0DYD5CqY0D5zF
         2tGN985suAlSwUdeqG8OTWZm+5k6XsIcM1tQMsx6pvWH78q2cRPnLG9bTM4dErr5xYB0
         zy/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f35si3570514qte.129.2019.02.18.02.29.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 02:29:40 -0800 (PST)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1IAL1SV096577
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:29:39 -0500
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2qqrhmehg4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 05:29:39 -0500
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 18 Feb 2019 10:29:37 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Mon, 18 Feb 2019 10:29:32 -0000
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x1IATVL944957846
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 18 Feb 2019 10:29:31 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id BFDD311C04C;
	Mon, 18 Feb 2019 10:29:31 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id E723011C054;
	Mon, 18 Feb 2019 10:29:30 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.207.239])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Mon, 18 Feb 2019 10:29:30 +0000 (GMT)
Date: Mon, 18 Feb 2019 12:29:29 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
        hughd@google.com, viro@zeniv.linux.org.uk,
        torvalds@linux-foundation.org
Subject: Re: mremap vs sysctl_max_map_count
References: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
 <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a11a10b5-4a31-2537-7b14-83f4b22e5f6c@suse.cz>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-TM-AS-GCONF: 00
x-cbid: 19021810-0016-0000-0000-00000257B7CF
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19021810-0017-0000-0000-000032B1F5BA
Message-Id: <20190218102928.GA25446@rapoport-lnx>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1902180079
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 10:57:18AM +0100, Vlastimil Babka wrote:
> On 2/18/19 9:33 AM, Oscar Salvador wrote:
> > 
> > Hi all,
> > 
> > I would like to bring up a topic that comes from an issue a customer of ours
> > is facing with the mremap syscall + hitting the max_map_count threshold:
> > 
> > When passing the MREMAP_FIXED flag, mremap() calls mremap_to() which does the
> > following:
> > 
> > 1) it unmaps the region where we want to put the new map:
> >    (new_addr, new_addr + new_len] [1]
> > 2) IFF old_len > new_len, it unmaps the region:
> >    (old_addr + new_len, (old_addr + new_len) + (old_len - new_len)] [2]
> > 
> > Now, having gone through steps 1) and 2), we eventually call move_vma() to do
> > the actual move.
> > 
> > move_vma() checks if we are at least 4 maps below max_map_count, otherwise
> > it bails out with -ENOMEM [3].
> > The problem is that we might have already unmapped the vma's in steps 1) and 2),
> > so it is not possible for userspace to figure out the state of the vma's after
> > it gets -ENOMEM.
> > 
> > - Did new_addr got unmaped?
> > - Did part of the old_addr got unmaped?
> > 
> > Because of that, it gets tricky for userspace to clean up properly on error
> > path.
> > 
> > While it is true that we can return -ENOMEM for more reasons
> > (e.g: see vma_to_resize()->may_expand_vm()), I think that we might be able to
> > pre-compute the number of maps that we are going add/release during the first
> > two do_munmaps(), and check whether we are 4 maps below the threshold
> > (as move_vma() does).
> > Should not be the case, we can bail out early before we unmap anything, so we
> > make sure the vma's are left untouched in case we are going to be short of maps.
> > 
> > I am not sure if that is realistically doable, or there are limitations
> > I overlooked, or we simply do not want to do that.
> 
> IMHO it makes sense to do all such resource limit checks upfront. It
> should all be protected by mmap_sem and thus stable, right? Even if it
> was racy, I'd think it's better to breach the limit a bit due to a race
> than bail out in the middle of operation. Being also resilient against
> "real" ENOMEM's due to e.g. failure to alocate a vma would be much
> harder perhaps (but maybe it's already mostly covered by the
> too-small-to-fail in page allocator), but I'd try with the artificial
> limits at least.

The mremap_to() is called with mmap_sem hold, so there won't be a race.

But it seems mremap_to() is not the only path to call do_munmap(). There is
also an unmap in shrinking remap and possible move_vma() even with
~MREMAP_FIXED.

Maybe it'd make sense to check the limits right after taking the mmap_sem?
 
> > Before investing more time and giving it a shoot, I just wanted to bring
> > this upstream to get feedback on this matter.
> > 
> > Thanks
> > 
> > [1] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L519
> > [2] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L523
> > [3] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L338
> > 
> 

-- 
Sincerely yours,
Mike.


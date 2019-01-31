Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F8D3C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:10:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEF562087F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:10:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xEEBLGq1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEF562087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EDBB8E0004; Thu, 31 Jan 2019 03:10:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79D898E0001; Thu, 31 Jan 2019 03:10:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68D8A8E0004; Thu, 31 Jan 2019 03:10:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5548E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:10:34 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id z6so2682953qtj.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:10:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=3voy6zIBkHur9+pvFM+1PirERab/y7Ul2U1rVnE912w=;
        b=TnBOrh1Qbqv7eUfZhKCW0mktCdH5tohEVnjQBIaq36ajW3sJzhsFrYby1tMtBmKIb+
         zH5+8PhtjWr7mC5Yeee94ISR5iHqpO2+q2negzDMLzJCImDotk0RLP4zQfp943f4D6PU
         md72Qsw9Dst84nY8PYiua6q54WFAkU91ESH+JD8PtU5uMQmPXguyqWMA6RZ53yT9jznx
         9kZMmjm9fiGNPWk1ErTmBMcu+HcMRsibCnmi8CuHIXbdAnnUGuAbXTWQ36M3A2KcPSMY
         aJq6aHyhKVeMebEcXooJTa56jvBKJ4dU9v/8lYHCxcjWY7fLZyS7FPdj1o6JStAVwyzy
         qfiA==
X-Gm-Message-State: AJcUukc17ZlNli8owV3wxCattR1oaqQcSsSb37oLv2+6gWySTwXsIR6g
	3aKRIT8I0BtNhHDmcmPSG7kilsVfwxkuUhgt4C1Qt8oGY3vGE4MsGNS4Nei1fhR2URwYOAMElXw
	HW+wyYJmevhVw7HtP4x4rhb5tBc9AwsuJTxYgodlWpdOIGuLu3oPj3ycJNc6fVMYj7w==
X-Received: by 2002:ac8:7950:: with SMTP id r16mr33341765qtt.12.1548922233895;
        Thu, 31 Jan 2019 00:10:33 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6Xy4zUXwdGHFInrumxH5lwUlduSlmiEgcofVU1adCCJgA0EcWrXHP7DVUMktjfxODews04
X-Received: by 2002:ac8:7950:: with SMTP id r16mr33341744qtt.12.1548922233364;
        Thu, 31 Jan 2019 00:10:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548922233; cv=none;
        d=google.com; s=arc-20160816;
        b=Us6CfVOs3slE9wnz6gQAs5rJyTEQSiXLKepOEDN6TwsH2lwlXf8ClFYAO5EiJO1YWT
         VFIzlUvKNz/DdG00QKPt2fhOOOFE5oUvQUejjeAuldtKSFfY8xfzyRgVRT9gVkoDp9Ut
         V21dsra42iEN0YvLG4uxGNchaSASyDXn9hG/mL7Hhok1UWXYr3D6ORU8OzPyz8Ax91DV
         A1lYUaKj8ZqoTLInvT0peMPWk0mPbRhgI/Ch1N37MPti08ZWGIFkc4pR6Ic9eX81D4OK
         8tuNHsKLCfmpLeBR/AAlwVJjM459vxgJIdFlQNzYY+9zJMXGTyWiX4hUy+nUSx/P2z6x
         gOkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=3voy6zIBkHur9+pvFM+1PirERab/y7Ul2U1rVnE912w=;
        b=lpIjWI5mtedbtfUldTQnPYKKgbS+IZ3VaoLQWSqAOvZ06CTEU6+pmO88kjbeCCDQcA
         foRIqqVx1CD+2OFFx4fIXLi9UR187E5jvYxqOtV7eT3kqN5HI5kpMJ6pZz7PCMQpu/x+
         dPyjJ03/9Wa4Gvn67cu1z0HOpVlIHSDaf4wkWkWB293k1369jyk4JaLL1ESn9RiWV0NR
         qqztNa+1TBxiy0t0aFaUx4Wi4lmvPWu52KV5wVw04B4O/V+OaCrD0e659FZaBFft8iCF
         PguzZdgsM/QQwnzIkR/T9tQEmAK4enVFXq2jxMh/cUqZkibT7ExFBxl9B1pdAZemQMYo
         J36w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xEEBLGq1;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c48si349175qtc.275.2019.01.31.00.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:10:33 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xEEBLGq1;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0V89Dax072376;
	Thu, 31 Jan 2019 08:10:29 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=3voy6zIBkHur9+pvFM+1PirERab/y7Ul2U1rVnE912w=;
 b=xEEBLGq1w9R3WG9WKXYWXehNFcZmO86pC8b/GDyl32CYyYz3zbHoiWTWIZk5Ka0B49TC
 cDqPbqP1YL+Yr78T5gJktGgI+HN5+GV1kxxPhSJ134nGjN8ZEwkqoV1BauK/Hj9rAtUP
 6PGQuSYb25cgpFZ/eQEccrkDY+muJCBilnsVFFK2PTwJtjAvAdk9ycaneeJ+6LI2IWBY
 ze8wqy/jtI77UfGDScsSmmhn3xTan6Wr6YPBp2QnMzy3R/dPapCrJCPfYumBTqUa6FOm
 kcza7MoZ14hGpL1WHYZJI93Ud8Y/6nRP13boZSGMTEDieGRHU9WUtRTiyJHiKM+sM37b 2Q== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2q8g6rex3d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 08:10:29 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x0V8AOXR029293
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 08:10:24 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0V8AMvk013389;
	Thu, 31 Jan 2019 08:10:23 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 31 Jan 2019 00:10:22 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.1\))
Subject: Re: [PATCH 1/3] slub: Fix comment spelling mistake
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190131041003.15772-2-me@tobin.cc>
Date: Thu, 31 Jan 2019 01:10:21 -0700
Cc: Christopher Lameter <cl@linux.com>, "Tobin C. Harding" <tobin@kernel.org>,
        Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <9C8C1658-0418-41A9-9A74-477DB83EB6EF@oracle.com>
References: <20190131041003.15772-1-me@tobin.cc>
 <20190131041003.15772-2-me@tobin.cc>
To: "Tobin C. Harding" <me@tobin.cc>
X-Mailer: Apple Mail (2.3445.104.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=470 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310065
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jan 30, 2019, at 9:10 PM, Tobin C. Harding <me@tobin.cc> wrote:
>=20
> Signed-off-by: Tobin C. Harding <tobin@kernel.org>
> ---
> include/linux/slub_def.h | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
> index 3a1a1dbc6f49..201a635be846 100644
> --- a/include/linux/slub_def.h
> +++ b/include/linux/slub_def.h
> @@ -81,7 +81,7 @@ struct kmem_cache_order_objects {
>  */
> struct kmem_cache {
> 	struct kmem_cache_cpu __percpu *cpu_slab;
> -	/* Used for retriving partial slabs etc */
> +	/* Used for retrieving partial slabs etc */
> 	slab_flags_t flags;
> 	unsigned long min_partial;
> 	unsigned int size;	/* The size of an object including meta =
data */
> --=20

If you're going to do this cleanup, make the comment in line 84 =
grammatical:

/* Used for retrieving partial slabs, etc. */

Then change lines 87 and 88 to remove the space between "meta" and =
"data" as the
word is "metadata" (as can be seen at line 102) and remove the period at =
the end
of the comment on line 89 ("Free pointer offset.")

You might also want to change lines 125-127 to be a single line comment:

/* Defragmentation by allocating from a remote node */

so the commenting style is consistent throughout.=


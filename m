Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 574CAC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:03:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBFB12084B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:03:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="h44Q9GKC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBFB12084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A38996B0266; Thu, 25 Apr 2019 08:03:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EA9A6B0269; Thu, 25 Apr 2019 08:03:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DC196B026A; Thu, 25 Apr 2019 08:03:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57BCC6B0266
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:03:49 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id j1so14523377pll.13
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:03:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:to:cc:subject:from:organization
         :references:date:in-reply-to:message-id:user-agent:mime-version;
        bh=OaQXF2xxVWVnUHUhb2JG+w385O56qSOrtvzv3Jg//pg=;
        b=Bi8yXivTiL43zPJ4GsdbWhPrD8CDQfptp4yJKFgY5+oXQaf7vZdyYuX1I7X8p3L1fR
         sHrh8QKEy5EGp/iz3+FQRUE0ZajPqlE8AnXL8OZaFzC21Ct5R6rIG0yEfFk9T9T0I7ND
         9DeXmk8ZEDimMhDghH3Lro+ivitCfADHS8eMT9x284H/hT7NC0Gkx7v2TcM/ZQcxT+w+
         wI/CnLXVpohlO3kxOQZ3X+rAEOPxYauRljXTzxFJZN+GR6mAlaBH5CFNd5KqJH9guO1B
         VVQJiysClBIgmHwMn7O381wvaJYcqMd4MVOIyT1tQXx1VJvx+GHORVynGLaF6i4wAiIr
         KCnw==
X-Gm-Message-State: APjAAAWPR4E3F81Ts2afs4qfQDRfrHJ/6lgYzJ7hv7aA8WbVMiWQMVWc
	Is95BWm9M5wqd0TCRUOOAd7tSm/gqapkB1g1ZAboJPrQdQCyTZiPHOvPPd+Pz4ytuqV3ERBW7Mi
	/NuXkwkxjKvau8VfJq2pXa6Q33L8BGZf2xym6yWqVAy63Wmd/UnpqlroVElid6k6YRA==
X-Received: by 2002:a63:6804:: with SMTP id d4mr36898075pgc.240.1556193828913;
        Thu, 25 Apr 2019 05:03:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5/nACg1oGljTh3NeXVJTCqvDiyPk4lADvaDVrKVd09AgJ/CDGccXHZNa6w57GHe0BZ+aw
X-Received: by 2002:a63:6804:: with SMTP id d4mr36897905pgc.240.1556193827307;
        Thu, 25 Apr 2019 05:03:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556193827; cv=none;
        d=google.com; s=arc-20160816;
        b=hlp6krzOMd0lbFOUTfEb8+mWSl3jqdV21SP0HhqPELHGU2JXaKJxtMD5/BNb7l5Gdg
         yOr8GeqWADz5UXXGNB20xyNKxQc/QyCR7br5NE021o+QDH+LFnVWwlKOsPCQO2UMrTtI
         CDreRJbdAz8L7DcmuhmqN0+pikjxaebgrZfyJ8jsAdptaLbVpOtTfOzvT7tlvxXaOkMx
         j2TFNQEcHgT5zOGSyHxZCSoc3oEnqsQi77WJsAW7eZb6u3Xn7EFg2e1xjL6dfVwiw0HX
         ZtV84L2gBgx8fiqab7Oo7hKq9ncv6JFp1cf3hOG6x8gvthx5jwaEb7DqgJcGeIBTpS55
         F0Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :organization:from:subject:cc:to:dkim-signature;
        bh=OaQXF2xxVWVnUHUhb2JG+w385O56qSOrtvzv3Jg//pg=;
        b=Jduw0fHD2amle40jpv7dAkiNwF/HuZCIlixOMGnMwNcA+/O2ItGSdgJw6sjgLVFxzY
         p8Vf7q/Yor6ZsOpNl2W1jWaf2PfSjGR4FtPPfro/z0VIVc2XW+VdahU5+ETxKD/6PWz+
         aIHGTT1tClK9glrpeXs7eYI9FeAC5cFu4KXZmk84stHrKFB69M3+WwvGHyBVDMhP7LnT
         NKFLlxuZLXVuPwo+zQPO3FiW3uTVazs1ObDjYqyMPbBjZf//XX4p3BK8q1eH6ivEuuxC
         LuGxQoC4iKx6CJxTiuS6vzuqA8+oKFmJsyTCO/RCW4vkZWFvNGC12Q8zFgEtCdy+HnM1
         fj5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=h44Q9GKC;
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id p66si23810843pfp.228.2019.04.25.05.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 05:03:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=h44Q9GKC;
       spf=pass (google.com: domain of martin.petersen@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=martin.petersen@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3PBxF7t071723;
	Thu, 25 Apr 2019 12:03:15 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=to : cc : subject :
 from : references : date : in-reply-to : message-id : mime-version :
 content-type; s=corp-2018-07-02;
 bh=OaQXF2xxVWVnUHUhb2JG+w385O56qSOrtvzv3Jg//pg=;
 b=h44Q9GKCE9DpIDwyNlDyxU+KU19sLHa6VO1D4lCcWzv+h3G41sUuivZ35l+LZU68EvXz
 iIhk6iGarH454XZQLpTzBVVHhKi0vOZIRR90/w5owa9zp/E0QiFlqZ9lb5ny4H8tFVmj
 ILCMQglLlBKgskiRSIcH/lwStZgpRgeUc+KbTtRmGtrUFYuCZacVVZPtfUahoBHHO8O0
 cJhN+ldTaD4I/H/QzTwvlPY2PBjqZkN/gv61Old8RqgZpHyoJVpH/ykcpfXDlgEe9P+I
 cXQxIkc25DqEjBzP1V4kzO52i+VbcMfG+l30DKqP8cYvVPTh0JvnmPm/kptb+sTiw/Y1 kw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2ryrxd83hu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 12:03:15 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3PC1MUA187819;
	Thu, 25 Apr 2019 12:03:15 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2ryrht5vh7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 12:03:14 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3PC3AfS025228;
	Thu, 25 Apr 2019 12:03:11 GMT
Received: from ca-mkp.ca.oracle.com (/10.159.214.123)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 25 Apr 2019 05:03:10 -0700
To: Matthew Wilcox <willy@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, lsf-pc@lists.linux-foundation.org,
        Linux-FSDevel <linux-fsdevel@vger.kernel.org>,
        linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org,
        Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>,
        David Rientjes <rientjes@google.com>,
        Pekka Enberg <penberg@kernel.org>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ming Lei <ming.lei@redhat.com>,
        linux-xfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
        Dave Chinner <david@fromorbit.com>,
        "Darrick J . Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
From: "Martin K. Petersen" <martin.petersen@oracle.com>
Organization: Oracle Corporation
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
	<20190411132819.GB22763@bombadil.infradead.org>
	<20190425113358.GI19031@bombadil.infradead.org>
Date: Thu, 25 Apr 2019 08:03:06 -0400
In-Reply-To: <20190425113358.GI19031@bombadil.infradead.org> (Matthew Wilcox's
	message of "Thu, 25 Apr 2019 04:33:59 -0700")
Message-ID: <yq1zhoe70n9.fsf@oracle.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1.92 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9237 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=824
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904250077
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9237 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=846 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904250077
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Matthew,

> Do we have an lsf-discuss mailing list this year?  Might be good to
> coordinate arrivals / departures for taxi sharing purposes.

lsf@lists.linux-foundation.org

-- 
Martin K. Petersen	Oracle Linux Engineering


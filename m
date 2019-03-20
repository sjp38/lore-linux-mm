Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 441F7C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:55:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFBC12146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:55:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FE175wIn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFBC12146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A405A6B0006; Wed, 20 Mar 2019 10:55:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EF336B0007; Wed, 20 Mar 2019 10:55:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 904E56B0008; Wed, 20 Mar 2019 10:55:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C5BE6B0006
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:55:39 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id p1so3432257ywm.6
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:55:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=vyTalyJPAp/99xZSU46vuHhBhzH/5qMxRbhLufZJza8=;
        b=WpripNtxe+9xYbYcz2y0sNhUgd3hWwB67Dzt2IQAVCC1Lh3nByU9/QiT3PTgMDlDN7
         Fyiv5OTXUgmgq7xFx4FpFUIUD3qcTOUJiFgS/M9BAXSzEur+DiejFbMWthBvuAkVtN2w
         +5nUAzjv4HyD8Lzv7tkyLQNQmV8eAgdOQPAqzw1zyDRA91pGl57oWJdRtOXmkG59+4EF
         UmkwF8pd6WmW5Eub8hc9wm8h4gQaCfncv7LT2oMIPxz1Pq9lt8Pv7FtP8YYwAdXzkDew
         Ji8/tHd4jpg5uvBNAmQb1vuKamf++O6EbdgiHwqhPVsKKiS+lxWz9DTdWIdU9myXeH+W
         dADA==
X-Gm-Message-State: APjAAAXAkH7yw77+4pSJiWXUuZP0oZrcjpf8UN/em4Aq7cuadUi0DSFY
	azd3RPxKPLL7lpCZsHzNImLqZa3pXjiKpPWprmL+yfFnRM1y2jki/cQiXv/ZyOSJoz0YWJtI/nx
	smAiCt8tjOk0Cbk0bU9wSejXizLbUIC9kARxvD8yvRKrzaR0dcjlgsMe+XJMygCMDng==
X-Received: by 2002:a25:5782:: with SMTP id l124mr7473680ybb.114.1553093739208;
        Wed, 20 Mar 2019 07:55:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyZUVbJy71pEbJSFBMpsku/D8awdc3CurIqeK671YN68ziDIxAkYdC2+gTxeiOuVnFGzjIm
X-Received: by 2002:a25:5782:: with SMTP id l124mr7473639ybb.114.1553093738596;
        Wed, 20 Mar 2019 07:55:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093738; cv=none;
        d=google.com; s=arc-20160816;
        b=oTHklRfhol5lRJc3Hwa/wfWXwIbzs0j6TUcvb2XYhGy7M74ziUJTS4m9b7Vfk9a/PD
         mxcJuvAymiSSgPOuZZd7aix9pLMnAC8cpaTENHwQ2kpsYmqxpMvupPXackLbftoTYT5g
         G4fWB4pkszRihj6pux0omb+EWegRCg/5fsYJaWqe3kBA7NAiHaJTTyNPZsVsGoatjAFn
         3e1X5k70yH2hbR22A4btCiMQ7JYlyZWzVQbJa4Y+Z/+8cMK6w00HdSLXJI+0o4o0aL7k
         VCNKr2ZY9dGww7yOGGU+WZB5UJVijv3C5n30xRTQxJhQES7DNZ36NakGpCRLwsRqQ/7s
         uvMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=vyTalyJPAp/99xZSU46vuHhBhzH/5qMxRbhLufZJza8=;
        b=pAAsK4xWhfEF00uJtIghel0PrhEQfl48WVbSUXEpFPvKzrsr6IlUXPfs6udmuo5lgI
         hbAm4zA8mJ00u0cy5HSQ/myMqOGP2kryUfRezK6thSwoXwImxCX7ZbBVRn/7E/lj7QX3
         Phl/cmDiYLJNkw07Kp3CgEBaZN25pobvvwOU+1NsKOC5B0CSgSa43Lr9VxYykj1MUydZ
         j59TV9v8vq5OkSJu3qCCnYuscR89sJDNju6z88JAPMDufQ4mLQcTrTNdzxOONoWO0SYP
         HwP2H46NweTWAXw5nSWeqSr0YHVwoV0mZIa2phNphYqp8V/h4P0DPXcKsTn2AxMdvZB/
         Qczg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FE175wIn;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v64si1348407ywb.297.2019.03.20.07.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 07:55:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=FE175wIn;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x2KEhaFt051492;
	Wed, 20 Mar 2019 14:55:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=vyTalyJPAp/99xZSU46vuHhBhzH/5qMxRbhLufZJza8=;
 b=FE175wIndmjYqE9O1h9gs5/x/125rxIpTQyFuF9GQH3a6Qt22P3l4AlfYcZkplEIkwNy
 gL7VbxXqStMmQzDd7xdU1b0A57BVB8eoyezOVk6OCl1t5a1UMdVoKFq4Vw0/CxJ6C1ni
 hmF07JbaCWoErWy1V+EBBGOgYuvfftQ/Hclxb2Zh2YcX3qht8+vjjFLgvQpBSmpNyZeV
 FgHRKu1XeXc2w2qeNDJlMGA6OfsAYO+/xVIdbTPWmIgQ6xIjue2c/pJSTFqvDG7ArIP8
 poCyhKg1J2b1Do1V6MWmoC7XL59Xaz+0GVdd/oY+2XtrqWGOcat534VBi/iLvPAvW5y6 dQ== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2r8rjuubhn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 14:55:24 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x2KEtMju002103
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 20 Mar 2019 14:55:23 GMT
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x2KEtKfb010967;
	Wed, 20 Mar 2019 14:55:20 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 20 Mar 2019 07:55:20 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190320043319.GA7431@redhat.com>
Date: Wed, 20 Mar 2019 08:55:17 -0600
Cc: John Hubbard <jhubbard@nvidia.com>, Dave Chinner <david@fromorbit.com>,
        "Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
        Andrew Morton <akpm@linux-foundation.org>,
        Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>,
        Christian Benvenuti <benve@cisco.com>,
        Christoph Hellwig <hch@infradead.org>,
        Christopher Lameter <cl@linux.com>,
        Dan Williams <dan.j.williams@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
        Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
        Mike Rapoport <rppt@linux.ibm.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        Andrea Arcangeli <aarcange@redhat.com>
Content-Transfer-Encoding: 7bit
Message-Id: <BFC3CDEE-4349-44C1-BE11-7C168BC578E1@oracle.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com> <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard> <20190319220654.GC3096@redhat.com>
 <20190319235752.GB26298@dastard> <20190320000838.GA6364@redhat.com>
 <c854b2d6-5ec1-a8b5-e366-fbefdd9fdd10@nvidia.com>
 <20190320043319.GA7431@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9200 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=913 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903200113
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Mar 19, 2019, at 10:33 PM, Jerome Glisse <jglisse@redhat.com> wrote:
> 
> So i believe best we could do is send a SIGBUS to the process that has
> GUPed a range of a file that is being truncated this would match what
> we do for CPU acces. There is no reason access through GUP should be
> handled any differently.

This should be done lazily, as there's no need to send the SIGBUS unless
the GUPed page is actually accessed post-truncate.


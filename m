Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4176C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:14:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8549921904
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:14:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="xzkmuFRX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8549921904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1D1818E0004; Wed, 13 Feb 2019 14:14:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17F058E0001; Wed, 13 Feb 2019 14:14:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 070F78E0004; Wed, 13 Feb 2019 14:14:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D34998E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:14:29 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id k19so2432826ite.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:14:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=avSS2COdBnrD7yzLYWOeBE8KFth7525BgEOTCADYvDo=;
        b=IEmz7LGM/eaN59OBc/iIZDqNOfT1ToofO5Jee0LG9E8h1cMQ4Q+X/6Vd3CQrTYKbi+
         FRpwtDPEpRPl4Wu7HRawWf+9eBdabmQ8F9ITsj5nyae9nNirDpNvrLwzjHn/gG9GLx7h
         9Y7ZRmuHZ+cCGewsvm/3lP6cyPE05A3Stsl//raKRZhadPWX2x2ck2BzDwp6/8uj7ek6
         yhZJ03HrS285RblyqwT1HTCoOOfA90DDPlxHUoANToyUXAXKNZWdEAaPxd2EuW6LfFqN
         GFTvuys3NVWb/yiUXixPDEAo4JgeUqDK2S9uqMdfs9qCMFo8rC+FUqrgMlVLmusAZXPx
         bcMA==
X-Gm-Message-State: AHQUAuZ0ZLFY+gL1NbdLRE8M4VJy0axrCOV4op0nv8xNHWKwog4mjfZ/
	hWH0006nfhE9DwuVZxGeDnflmrMjAKew5zlpK2FF+9tecAljN2zPZs0Jw77oIrAGyWoTVwmxk45
	AtlJ2Q3tffqH9SlTFg2TcdsqIyvMCl27zXNWiwAA0ZbY+7hQDKXi0r2JFNGq/BcfqNA==
X-Received: by 2002:a6b:c889:: with SMTP id y131mr809682iof.106.1550085269683;
        Wed, 13 Feb 2019 11:14:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZyl9hQbyAg7tJvZW8XE7MyUJIeid0Knfmkg7SWL11oww99H/P0oWnZ0igAtX94mBfb/p4y
X-Received: by 2002:a6b:c889:: with SMTP id y131mr809657iof.106.1550085269052;
        Wed, 13 Feb 2019 11:14:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550085269; cv=none;
        d=google.com; s=arc-20160816;
        b=okQ6mTd17LdUrHdR87tvlClqBlXEqN3eesKnTICMNHbfkRskPZmRLoeGV9gHe8b3/p
         BB2+LW3QGkKkADtHLFbSEu0+5Wo0ciy5on+9T4rSmtUa893/JKZq/jX2XBu6KSDC5VRt
         5w3R6qLINL9nzd0tG72UPynr8ir3gvcGfMPmukqMIRq/gmyUEuNLdWIqSn7upFRtJUSL
         ub6bZyb8fg2h9QIO38rrfPTaCYqpf4HL3l3anO2uJ+XoqmVVfsvcnESSiDiR70qnW0Qd
         Zpx/fZ0TTj0Bpxx63wjbCZY3p8vXm+u4WcnFuZiQ6MMbcVipRimH3oY2BLtWrxT0dIHt
         t7yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=avSS2COdBnrD7yzLYWOeBE8KFth7525BgEOTCADYvDo=;
        b=ug2bwgDqAVRxDfN/RqbaWyDj/NOjmvShRdjzHOw5PI28z3cLyPK3p4JprLDa8JtYpv
         Ivac3l3Oq7MzhM2tI+XKCTbtt/dhPoEVziHIOxmyTOLUXfgQ+ZAfuNkqJSQJkRIYc0/A
         Io4cYlSPK+IdX485ZVKH589xFf7yx1mx0N6H0wdxB1oZ07+VOevJ1LuJ99XOgLBkR5Hn
         BYZOJe213oMi4maRngoFwYlCIcOHd0tsS0+W4w/yoFp0+r1vmLlgoYDrPAI7QD8W8WyX
         Ped4q6EIBV2q4B/db0MuXHZqyV75NQUTZBsa74qrRRbB9A2I6WRfNTdE9RrGTZxTEDZG
         RMNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xzkmuFRX;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k68si53109ita.103.2019.02.13.11.14.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 11:14:29 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=xzkmuFRX;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1DJ8cn9066548;
	Wed, 13 Feb 2019 19:14:27 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=avSS2COdBnrD7yzLYWOeBE8KFth7525BgEOTCADYvDo=;
 b=xzkmuFRXOYVwUj3Q5QKmP1p74IZ4i2P8LKV2BG87EOWGWLfVmupi6rnH7szZvXkKMJPm
 2bdtZw9m/VR4Lo92OrpEZFaO7N9w8Crmkio+9tUnQ259eWUxiuN4keuS2xByxkb5OX+d
 NorfBYS+9JuGYc/21XZxcQwxzY1Lvdwd7KEbbZ4pNrgdX+inJNyuDPk3fIDaWOy7qUpE
 iNFlA+8Fo+C8vKLcm8x1m4wts+bqJ7tTyEdsoD6qX1EG3J4c+MMMXwaF2afr2kl6qPuv
 946wZ+QuZBGM92UCAyoCC65h8FVRerjOwKn2diTFDv1qZVeNv9EdZ74dNb8BLk1SsvGp Dg== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre5kx7h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 19:14:27 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1DJEPFI026991
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 13 Feb 2019 19:14:26 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1DJEPVt029873;
	Wed, 13 Feb 2019 19:14:25 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 13 Feb 2019 19:14:25 +0000
Date: Wed, 13 Feb 2019 14:14:46 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/4] mm: Remove pages_to_free argument of
 move_active_pages_to_lru()
Message-ID: <20190213191446.r3pop7kv6kp6b2qv@ca-dmjordan1.us.oracle.com>
References: <154998432043.18704.10326447825287153712.stgit@localhost.localdomain>
 <154998445148.18704.11244772245027520877.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154998445148.18704.11244772245027520877.stgit@localhost.localdomain>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9166 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=716 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902130131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000130, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 06:14:11PM +0300, Kirill Tkhai wrote:
> +	/* Keep all free pages are in l_active list */

s/are//


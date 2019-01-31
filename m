Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D6DDC282D7
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:52:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99E3C20989
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 01:52:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="htQ+TO19"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99E3C20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 119358E0002; Wed, 30 Jan 2019 20:52:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A22D8E0001; Wed, 30 Jan 2019 20:52:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5F398E0002; Wed, 30 Jan 2019 20:52:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2D028E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 20:52:50 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id d73so909096ywd.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:52:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Lp+YltMO/Rp4JseMOTLP1uHfi2eROk2VKW/VVreoTkY=;
        b=J1XTDL0z1mpUoxWNCrwvfFgk3MGowcq8/vm8t5/E+of3dK69VIJwwy1jLmgcZAGhVO
         r6NJDDNFrWYTkd2iTcnnU39BmofReUnx4KbqG5CExfw2JQrEtlPP0QWvkpz3t2VuTqbK
         f/VgTUyd9bfTrnKmXPDQTAPEuouoaSNKYMxFIxDg/40HLAB1EIJWyc3fydW27I+W7O7v
         iAbwH3+mxUeTcYI19vbeCtV0x4W7SapPSK92l44BN+FqfWXim4TG08Rk6WhbcndPKdtM
         ORXiFz+Gkj1qSxT1KQRsFCXYLYM3pyrQrrVJbF/J1HmFzUI6o0mW+dSHxzc5qGAwlXNO
         uR7Q==
X-Gm-Message-State: AJcUukf1UC37LZxoLXqPmhSbn/eJlWpE3Ldm3wppRoic0okdAwleXrJi
	UdLemh/TkyZkFmmp3mltygJduWVNf47jeE8wnZKPib1DKMG/xyiNFpEjq4eyf0lzhpxsQaOlSOM
	pGSXjS0SBJxoU1YnqUu4Ezzmtw4vb3U0gdJIErlcdWC10oCpGivoXTczI2J9TiRCLWg==
X-Received: by 2002:a25:2383:: with SMTP id j125mr27200760ybj.455.1548899570299;
        Wed, 30 Jan 2019 17:52:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5TjKHr2snpNNyYSjOk79mrN86bYapfNNlrRYSVkZbDxAEcbVxJzhXAnoF0/1rOzU0F+eyj
X-Received: by 2002:a25:2383:: with SMTP id j125mr27200740ybj.455.1548899569686;
        Wed, 30 Jan 2019 17:52:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548899569; cv=none;
        d=google.com; s=arc-20160816;
        b=SSL3DM/arB05Je1EXzkh2ACtRAsEoRHxq9Lzqd5P0creuZFh+dG+VgZEPGIdToon2h
         kEqQEgvKlL5481uPGxV4Bwuwdsg4dW442vIogY6zyg9XKzEU17zaJ0RaTqswI0a5KoWr
         3pq0A/s/BHvxYTzTIPO83NqP5PegZp8AEdyu+/Ad2TOSLqvACkRVpnsMeyk8Zqwn0b1A
         d4j0kLmBvgZEOToB52LKMM8Y1gI+gzKf/ZUO9y0EAslsWGMEmOXbjoIWXbK1iREq2jxv
         Z/IXCtqFuWs0qjB9TSfE5EO2KCeCUoFJ74vEhI5cWiyKJb8Cq6sxfct14VpqBD2DGmZw
         OGpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Lp+YltMO/Rp4JseMOTLP1uHfi2eROk2VKW/VVreoTkY=;
        b=sDKEbY7gz4bmP7GA2XCPtP36vMLolPEgLO6gOQSSYrh+XkyomQ5sv/Tyeo8V05P67I
         Xdc8c+cH29LrJ6TdCKZ9oPOLXjDsusfpyZNxcAbRmr2eZSkTy52IJ9kE8mPOWpzE5pPC
         sCZtOyQtd4Lw4mE3ofgLC7DQDsfEp/9Mo65+VL72zYhLFyW6ow5x2RGHV92iJAX7C9g7
         XtO/e8wfaK7FnhnA7bi47R7E2Po8O0IFW21T+vHpWH9Qt5v2cd7Gyn6MJoX2eBFUDMu+
         virUcb7Be9Q+CkhxED+kL9bUYfpLt6+HDLIqomreDwnC/QAXWfk+Db0lXFxllJWoRo1Z
         4mEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=htQ+TO19;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id r131si2062705ybr.45.2019.01.30.17.52.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 17:52:49 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=htQ+TO19;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0V1msom006818;
	Thu, 31 Jan 2019 01:52:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=Lp+YltMO/Rp4JseMOTLP1uHfi2eROk2VKW/VVreoTkY=;
 b=htQ+TO190vuIKl7asrTa47q/Dki6hVaawVoQ8Z0C7YKrAQ0Lah3P8NCqJK4cHb24JXcI
 dLIRRKJt1F95yc4v55kp9fO//ThOgVC2Dk46CjUpyIrNvDiAY/9YKlofDbahuELEQsNX
 3chZt10GstfY/VoQ3PdaN3NK3K70O8NL5+0+yqwSt5RVrVoawNqgHb8wv/6KofO04r1Q
 X3gUzxNEPIIpAVQaSUM2RtWouiYZYojZdY/K46nGLAiYa2EWB6f/j5ZwKgStYTRJIv+h
 Cb4Lr+KjXp/4bWnSIvbnyFaE35se0aci8iWI7Ek68TBtY6zsSD0OcSNbeylvSvuyxy5n 6A== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2120.oracle.com with ESMTP id 2q8g6rdu64-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 01:52:23 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0V1qGBZ016334
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 31 Jan 2019 01:52:16 GMT
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0V1qDqf024973;
	Thu, 31 Jan 2019 01:52:13 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 30 Jan 2019 17:52:13 -0800
Date: Wed, 30 Jan 2019 20:52:32 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, dan.carpenter@oracle.com,
        andrea.parri@amarulasolutions.com, shli@kernel.org,
        ying.huang@intel.com, dave.hansen@linux.intel.com,
        sfr@canb.auug.org.au, osandov@fb.com, tj@kernel.org,
        ak@linux.intel.com, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
        stern@rowland.harvard.edu, peterz@infradead.org, will.deacon@arm.com
Subject: Re: [PATCH] mm, swap: bounds check swap_info accesses to avoid NULL
 derefs
Message-ID: <20190131015231.e6lggsi2ug77qr6c@ca-dmjordan1.us.oracle.com>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
 <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9152 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=910 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1901310012
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000031, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 10:26:22PM -0800, Andrew Morton wrote:
> LGTM, but like most people I'm afraid to ack it ;)
> 
> mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
> stuck so can you please redo this against mainline?

Yep, I can do that.


Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC331C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:50:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79EB82081B
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 13:50:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="qnIlm5zo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79EB82081B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 134388E0045; Mon,  4 Feb 2019 08:50:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E4CA8E001C; Mon,  4 Feb 2019 08:50:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EEF228E0045; Mon,  4 Feb 2019 08:50:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 93B728E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 08:50:14 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c34so5877991edb.8
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 05:50:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sbpVy8mtwOFf+cy5P2CTmoiOEqIRp2+fSCpbVLdtP50=;
        b=Xm6oyAcdA79qyQQ743t8+1wtXRWJ56nbAltRbKr6sICmgmxNlqZeNNOGrTUUeCBkXS
         CXcEGRZ1C+A0BqZM60E22GqnLqyTTq7+4GzVgbM8zobv8IAuSkzyyoCj1IAk8r0dCj4e
         5u4fGN1onMJadBnBNcJiaWW2+CrZY6BXvYRVZF1P/okVXf/l849Iw9HY39bfkk1F+5K5
         NdmwxQamIGDYBl4VgcdhhJlaJqM6BNw/Xe+dzCbLOmg3zETd/Cak9JHgnUOtCf4rxVno
         YG7nXsOGxdfWhbd/VRiWJd9kq4Wolv1rGbwmiDf8lSVGB8b/gr1NE9A4gfkVCOHggPLx
         vuiQ==
X-Gm-Message-State: AJcUukfRrahPARfUo9K8Vvflmu1sGcUGAWqwA+1JSUibSfDfSXtULO8+
	WjKdQzNWdl7+TX2WvlQhEZCBh+yIcpLMwquCZnXinzAl3RWeDRudHsOXSZcDmRQCBRbi9YBdd5l
	G05s1xqucKxY3hgx3a9mEMPkGSuK3wZkhL/Z317h+CX0qk5n7F58HgljaeA1tNBAPiQ==
X-Received: by 2002:a50:aa9b:: with SMTP id q27mr50829739edc.93.1549288214189;
        Mon, 04 Feb 2019 05:50:14 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7SLKC+QAQvMG+yMIIaBRkLrPYcwlcWheWyBhop0cI/PYiSqpBrbVeWU6EZlzfq1yajYv34
X-Received: by 2002:a50:aa9b:: with SMTP id q27mr50829680edc.93.1549288213316;
        Mon, 04 Feb 2019 05:50:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549288213; cv=none;
        d=google.com; s=arc-20160816;
        b=EO5J9dqBHIwwswx9Aby30gsCiC2k5kTCqjw5p2N0vg2QA+VrUwGNYa8QDWfUXAeUyF
         jY+2I2LbjDH5aTLK4GxHwXX6xhVH1nJMukkEp47jdH927f7JfoMhYa5HC1cZXLnxauxJ
         0OM5paBkpN1cgBYm5vNEpFc8dUCgIg6+hwkS0TmjA1TpJzCPRadpVA3kVa0eIWGCuDAs
         DNWeRxcffhCrAiJnH13b37s/x+bqWPOSuaURRHA8AijKtMN7Pey8p7rS2Bk3YvAuI0wh
         zk+LOC08oZpEXDmuZN3Ou4vXH9DO0JdGJYP37KOl3AXrKdYS9jzWQhYLqKXlsPue6LNw
         Ny3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sbpVy8mtwOFf+cy5P2CTmoiOEqIRp2+fSCpbVLdtP50=;
        b=ki6+95tG6sReUJQ13eMo62xHn1P+F2hLuyjec73MjFi8OEUGMd5dojWQWgdt/t7lt2
         hK2L0+iUb60jyDr/9zf87eFbFicv4NyZ6nK4zFsdQY2PszJekn3xb9H8ymnAfD8wel+V
         6KwGORJjehur8K61P53keyVmT0cpDBC1sMGuqPdArlyWzlJ670FobWDbnnXkbPZmJ3ZE
         7Uw7CEq9o2a6pJ4mzbPB176FYpPbk5GvsQTtZAfHI4QSpX9xRAQUMdpcwgfnt5uFprMi
         eZ46cYYQu1dyb+qRhWsxwx1GcrgFfSoDIERRdFXPMvdzJEofOe5vrSCX7yiBqrJBUxac
         k5NQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qnIlm5zo;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id k25si1876055edk.323.2019.02.04.05.50.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 05:50:13 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=qnIlm5zo;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14Dhrgu006094;
	Mon, 4 Feb 2019 13:49:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=sbpVy8mtwOFf+cy5P2CTmoiOEqIRp2+fSCpbVLdtP50=;
 b=qnIlm5zoHjA1skAqrU8gfxZZXrGGZCMlOw3vlhh+RqmxjCTZtrnvWUq4jq1Lgf82LxEw
 D1nFfm2pdh04TMg18cUry3E1y/kaFi8gWMtooRbm+Aa8qZTOaHEezvY30W9nnCokCMgt
 n2nIegUOZAYZZcd6ReS8Jd/n1fvB4g+DG5VJVIQ8YURstP5dOeGJt2oZ2KINASSxDdg/
 NyN4lfOr5ojH12ttvNbnQ2vudkOdO6OgiBTwElWOpBh78K7sInF9e/FYuyMPOf3mNXON
 HIHla9FhMSX+R2H6Uj41MFc1cWtQ2n+02t0KqkVzo/rb0eWJecazBUDh3puRgSyXOyaP Iw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2130.oracle.com with ESMTP id 2qd97en70a-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 04 Feb 2019 13:49:57 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x14Dntoe022482
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 4 Feb 2019 13:49:56 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x14Dntre025648;
	Mon, 4 Feb 2019 13:49:55 GMT
Received: from kadam (/197.157.0.20)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 04 Feb 2019 13:49:54 +0000
Date: Mon, 4 Feb 2019 16:49:55 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
        kernel-janitors@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] mm/hmm: potential deadlock in nonblocking code
Message-ID: <20190204134955.GE2581@kadam>
References: <20190204132043.GA16485@kadam>
 <20190204134203.GB21860@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204134203.GB21860@bombadil.infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9156 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=759 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040110
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 05:42:03AM -0800, Matthew Wilcox wrote:
> On Mon, Feb 04, 2019 at 04:20:44PM +0300, Dan Carpenter wrote:
> >  
> > -	if (!nrange->blockable && !mutex_trylock(&hmm->lock)) {
> > -		ret = -EAGAIN;
> > -		goto out;
> > +	if (!nrange->blockable) {
> > +		if (!mutex_trylock(&hmm->lock)) {
> > +			ret = -EAGAIN;
> > +			goto out;
> > +		}
> >  	} else
> >  		mutex_lock(&hmm->lock);
> 
> I think this would be more readable written as:
> 
> 	ret = -EAGAIN;
> 	if (nrange->blockable)
> 		mutex_lock(&hmm->lock);
> 	else if (!mutex_trylock(&hmm->lock))
> 		goto out;

I agree, that does look nicer.  I will resend.

regards,
dan carpenter


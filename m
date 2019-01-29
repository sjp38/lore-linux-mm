Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3EA43C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:04:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3EB220870
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:04:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DrwC8faY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3EB220870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAC368E0003; Tue, 29 Jan 2019 13:04:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A83E28E0001; Tue, 29 Jan 2019 13:04:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 94BF68E0003; Tue, 29 Jan 2019 13:04:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC2D8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:04:03 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id u126so11891127ywb.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:04:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hSKpPqXzqyS0/SV7R2oQJKJuHzeEDOM2DM/byOS2nPE=;
        b=ssBc8h/VabqUd7bj2yGflkva0D0F/msfDyfqLbR/L+T6GmTMpG+NtQQU6pp+/QMCkF
         72KTTfrg9wiafLt4USfSHnvFSE1SL9YrWAR7H9AX+6s+fyWD6pSomDdxGnRzxqGSkUQG
         nQ4pJL1KzPI8y1SAg9AffLUdHHG5FBYJ1XwewyVOJWV6I+wr6zzemF0IoL1pgewUjxnB
         z/yTprVtmbw+Gixo1ixCmCmJWCRnJEZeM9ppna7d9EgD7TPth5S4/TcNv8lj3o9bSOs8
         TotV4e7CEokJBFR/BiHcXicb/RmZ3AGMDugReKY+dIk53RO+AR9yYT9nX8a+9jm07yqO
         16ug==
X-Gm-Message-State: AJcUukcgLc55I8uq1GkYQEffUpQp/LAw4VOTQkjP/6dIlGAZp33QE0aX
	C2UQ5BfwqsSQIWwCuVPSuEBk2rNNLN4usxriokHOE1K1wEL0BOmL/RSwQFl5yYi0EWgAul/13e0
	vxfuScgZ3zQlPX+LttKPSyfGqNBjgRa/Nvl1gifuQTkSTkE9CtjOoQn20Nds9uDg0vQ==
X-Received: by 2002:a5b:383:: with SMTP id k3mr25065309ybp.438.1548785042948;
        Tue, 29 Jan 2019 10:04:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7RgvmlPr5jZcrnahdBh+UW7z8k8v2SErsC20CS8RzXmeOBlYTZqunYlrN//U1Git4JkEre
X-Received: by 2002:a5b:383:: with SMTP id k3mr25065238ybp.438.1548785041977;
        Tue, 29 Jan 2019 10:04:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548785041; cv=none;
        d=google.com; s=arc-20160816;
        b=pkmYW5wmmSDsr9viuLEcAHScSkcMT6QtAseMVidwv94bzcZSCWD8efLjAu5bNHKLtb
         B9PnCv/ceNaqeeW8B6m8AyhMVjLskaFpjzdfXh9lEnRUzzCOTEXKSQUn9QiWVQH0Alit
         KHZ9+mUtaw0oCe9NZlmrUqT/6+ThNibtAvHT8a60ODnlPHXQ3IWhP3TZ34q/ip+kD3fG
         jP3NXLBCs4KTdIO3xVAYcDqiNsFfUhe/G7yzXm/7LY+I6G+zMlQF2HZBql6Lb2deWzk7
         9+6Reag0QkG4h8Ln/hovFOrp7cSuWbvz0qihA1pmP6FIqmvC8DgP4jvYqQJ24IGCUMoa
         oY7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hSKpPqXzqyS0/SV7R2oQJKJuHzeEDOM2DM/byOS2nPE=;
        b=S5YUnuHJ0VLWe+JaCkCpvPtyXb7Mj8IhU7h5PsXov+f91BksUXD7rlgbn1x+Z2Vj+J
         5a/F+26UxAkcDmqRvs6X6IuiZpBJWI2gy14cPKkW69J6DOS9jRIUjTqaU0bHvG8Zxmbp
         a0B3oahYshYDPlcxez+49Fd15p1/V7xLwkivX3Hgiwq0GMBxeCJS18V0oYBO6D68eLKd
         DTEpsNTGDAd2WclbKYYo0bozjooObhJvUn86JZwtnQDUI/WTFk5eueNzB+7vpYq15HjI
         x+SRE7aR4ddCfLg4ZLykd9DHlx3lluDa/dLTwYeVFwFHhC32CKvb7H/0C1h6v5+7PGV1
         23mQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DrwC8faY;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id b195si21794425ywb.332.2019.01.29.10.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:04:01 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=DrwC8faY;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0TI3u0l090938;
	Tue, 29 Jan 2019 18:03:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=hSKpPqXzqyS0/SV7R2oQJKJuHzeEDOM2DM/byOS2nPE=;
 b=DrwC8faYkPU/J6sB84xj1DowkgJQjF5drId5ngs5I1rEqXVBVPAlozZBLroX6nKF8XSL
 fUA7sgUgU2gyE9u+PCliwz/hEqK4v11tFLJnVr4QG/Y3Xi7kEP6XgeTH3+u/7lj0Gihf
 rEiV5xe25mZr3ngOjnk69IB6ixKBONu3nDEc49+b2HB0/jXYIn2LT/DKtVkB0meA37nt
 WERaX5+7mM5J5a2RtBd+XuD9Wa1uxikEbi/af81ootB3TqEVU/hSe2NYIL3PTdwMdJEa
 XupTpd8HNssU5N51RzGHXhE/CUzwhzbbfN9XKxP70ans+B3ovo9Np6zI8pYRkz5vRlcn Wg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2q8d2e690w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 29 Jan 2019 18:03:56 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0TI3tXB028794
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 29 Jan 2019 18:03:56 GMT
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x0TI3rTk028846;
	Tue, 29 Jan 2019 18:03:53 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 29 Jan 2019 10:03:53 -0800
Date: Tue, 29 Jan 2019 13:04:12 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org,
        ben@communityfibre.ca, kirill@shutemov.name, mgorman@suse.de,
        mhocko@kernel.org, riel@surriel.com
Subject: Re: linux-mm for lore.kernel.org
Message-ID: <20190129180412.fmxtfp3jcvua5gxv@ca-dmjordan1.us.oracle.com>
References: <20190129155128.kos4hp7rnqdg2csc@ca-dmjordan1.us.oracle.com>
 <20190129093858.826292029a1330beb89deed1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129093858.826292029a1330beb89deed1@linux-foundation.org>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9151 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901290133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 09:38:58AM -0800, Andrew Morton wrote:
> On Tue, 29 Jan 2019 10:51:28 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:
> 
> > Hi,
> > 
> > I'm working on adding linux-mm to lore.kernel.org, as previously discussed
> > here[1], and seem to have a mostly complete archive, starting from the
> > beginning in November '97.  My sources so far are the list admin's files
> > (thanks Ben and Rik), gmane, and my own inbox.
> > 
> > However, with disk corruption and downtime, it'd be great if people could pitch
> > in with what they have to ensure nothing is missing.  lore.kernel.org has been
> > archiving linux-mm since December 2018, so only messages before that date are
> > needed.
> > 
> > Instructions for contributing are here:
> > 
> >   https://korg.wiki.kernel.org/userdoc/lore
> > 
> > These are the message ids captured so far:
> > 
> >   https://drive.google.com/file/d/1JdpS0X1P-r0sSDg2wE1IIzrAFNN8epIE/view?usp=sharing
> > 
> > This uncompressed file may be passed to the -k switch of the tool in the
> > instructions to filter out what's already been collected.
> > 
> > Please tar up and xz -9 any resulting directories of mbox files and send them
> > to me (via sharing link if > 1M) by Feb 12, when I plan to submit the archive.
> > 
> > Suggestions for other sources also welcome.
> 
> I appear to have everything going back to Feb 2001.  But I am
> fearsomely lazy.  I can upload the per-year mboxes to ozlabs.org?

Sure.  Thanks for helping.

Other people are welcome to do similar things, but please share the files in
mbox or maildir form, lest I run up against my own formidable laziness.


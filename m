Return-Path: <SRS0=HgWV=RT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56096C43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 03:04:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36D420645
	for <linux-mm@archiver.kernel.org>; Sat, 16 Mar 2019 03:04:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="wjZA7/iC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36D420645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 44AB46B02CD; Fri, 15 Mar 2019 23:04:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D1EE6B02CE; Fri, 15 Mar 2019 23:04:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 272896B02CF; Fri, 15 Mar 2019 23:04:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D82246B02CD
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 23:04:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id o67so12411062pfa.20
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 20:04:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EGYYLBmFVTvG2g6ZUAcnNQTSk4rLA2Fs2LqO0pKWWPc=;
        b=sNMgpmuwuoywyHqTUg2s9cl3UKzasn5AyjqfMwVZ9Xt44MRYTHHtZvEKT20SQCpC9C
         hOU93K1LiC7eSzggDsXwUu4JhlVQb2GiqCYBHvRgfnfX4Kl6OAtsPrOxQUCTU5zPCzZR
         tljwoj17aSjSqO6HPaKynOhfCfTHfT3pAsm9cP2aFycAfvjWo/kfjCrd5xICTYGmfYuE
         1hc0hhT7b6hPBuqqoxBlIVLSkIob0HkyQL1s3pQCM/6nhEOLpUufKbx+FEWecES5kkT3
         TrHukaStrn8aHNlOZY5WeUprLMhuX2jtfUT6IaONAkA7pgBhW675ZV1GBrTO08+udtWR
         ZnDA==
X-Gm-Message-State: APjAAAV2Aoi7FiEpHJLEbwSVG8k55sARQByplVVY1hdKHRxugD3Sdqzl
	3UvSObRp4YODDGpmKMUDjZ5HEZEJGxyJD8dhb8QCKwSVebPdofUMpVLO5Txz9bDO1mnBhCDy6gk
	QnhMPDtwSl2Sa47E81C7RwtDbeO8rsRDFbTKn/EjInuFOgHd5Zp+rXrAEJ7InJxAz1Q==
X-Received: by 2002:a63:d256:: with SMTP id t22mr6812410pgi.108.1552705457463;
        Fri, 15 Mar 2019 20:04:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNWRHn5DnHNbrdyfAcdCPFn0koEDpDJwLzA9v8RrCI2GTfadBwo4nx36Hs8tMujt1hSekn
X-Received: by 2002:a63:d256:: with SMTP id t22mr6812340pgi.108.1552705456256;
        Fri, 15 Mar 2019 20:04:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552705456; cv=none;
        d=google.com; s=arc-20160816;
        b=TRZZhfj4B12s3XDafyaXWozDNSkv6CFoA0nZg6r727cUp+BORb+OrW9lHRRLJsPLwk
         ik0vJKf0gxP/UA9LzV3eiMTDtvr0II9EYG5dvizkwcDEM8b1Og7hzgADf6CE3YBOwTYS
         4Ke3n5Mf9CQVcgedLdW1FpkG/tVuLJRrILBO+4gvVqwhJ61LNrvi7khJMrFk+baj6SjB
         65paD38klIHIOB55DYtRPhvQzDTEMJYeMlc5nBdpr1QFCRuEQ3LS8ctw0Z2AQMnFKRLV
         Vm03/iUoakV3LF4qif8pna0/IjU/90p8EYI8NH/ctOX1twXtgi4yCfLz6cT0mbWL11kv
         Oh9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EGYYLBmFVTvG2g6ZUAcnNQTSk4rLA2Fs2LqO0pKWWPc=;
        b=YsBxS+JHnojj/1GL2naSO0Dwe2wapajnPP51OsUHfu93keLZ3tweUszBPc7uAkgJcW
         eSwrHfVOHexughM033Mxun0XQ9tcE62NUvqPe2mLG8uUquvZWJJ058g2JkXcjYZ7q1y5
         voqZAiHcU3aSSky5hd1Dza3DETyVx/WUUFAwDlwTYJ02fvQ/QgpmD9CZFGxf9yEWuY1J
         pCIZ0t/dZgJ3NSqeADMIgSpdwwlHBlav7/UeMo6YiPAhOeV4X2XWCIPCXhIWq8tpuBkQ
         wk7mm3WVM0k0b+1sjDJYXt2yI4bzQDG2GVQ3Gcq4FNUxarsZGEOAw/sUmFrYRrTBNXOi
         9Ing==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="wjZA7/iC";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p2si3362334pls.167.2019.03.15.20.04.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 20:04:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="wjZA7/iC";
       spf=pass (google.com: domain of gregkh@linuxfoundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=gregkh@linuxfoundation.org
Received: from localhost (unknown [104.153.224.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8D52F218D0;
	Sat, 16 Mar 2019 03:04:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552705455;
	bh=kHlO8sPVt6f18EIgoXLMolRqSxQ+DkKueBe7dfzK99Q=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=wjZA7/iCaiuQmLw9ClUnEIwhUPErtyXOYPsGpY5fT0XZjzyTHlVkTKEyznEKE43yP
	 3tkcMKukhVnLgQ30r2m4U79QF5N+JaijdkMloCoQbU04jFc/I6ERWwbBXTaB/qqcE6
	 EuiBabJUSXi5fV4YyOuEao/7D2g6/x2K4DJFgzh8=
Date: Fri, 15 Mar 2019 20:04:07 -0700
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
To: Keith Busch <kbusch@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>
Subject: Re: [PATCHv8 00/10] Heterogenous memory node attributes
Message-ID: <20190316030407.GA1607@kroah.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
 <20190315175049.GA18389@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190315175049.GA18389@localhost.localdomain>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 15, 2019 at 11:50:57AM -0600, Keith Busch wrote:
> Hi Greg,
> 
> Just wanted to check with you on how we may proceed with this series.
> The main feature is exporting new sysfs attributes through driver core,
> so I think it makes most sense to go through you unless you'd prefer
> this go through a different route.
> 
> The proposed interface has been pretty stable for a while now, and we've
> received reviews, acks and tests on all patches. Please let me know if
> there is anything else you'd like to see from this series, or if you
> just need more time to get around to this.

I can't do anything with patches until after -rc1 is out, sorry.  Once
that happens I'll work to dig through my pending queue and will review
these then.

thanks,

greg k-h


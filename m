Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4761CC46477
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:07:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E0BF720866
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 02:07:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="MTtnxOj8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E0BF720866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 319B86B0266; Tue, 11 Jun 2019 22:07:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C9466B026A; Tue, 11 Jun 2019 22:07:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1919B6B026B; Tue, 11 Jun 2019 22:07:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C220B6B0266
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 22:07:51 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b33so23421568edc.17
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=e3TEzE60VRj/MS8YEEehOOQckYotYtM00jSjKCi8/jI=;
        b=diQQ7zTYcbYqheVkSpMTs7og9dpXd+VkkE4seSqa+TLH95Klq2nL8huuxBlIi12tuq
         5cBSA5Lj4TJfTpqq3KzbnQXtoV++nMWxlpmOvEhovg+NOZ8lQWZNhtev1D/hUKQh84jk
         PaA9VjouIoEU1d42XgNzGqdat8IKK1vqfcHfmO0rz0uRJl1kdPVCgElHpejPio38EmS2
         fx1cjTAzmSWhwaBbZjkaquoOaLWmn66wieBlDU2j3TuS9ln924AKZNh8c89421PM9B2s
         JtWSyVn3MKaPzqbbbRE/DveuSf2FsOJ8wgpiYHHp+WXIJPFZfTUcOwri7AC8IAslR9xo
         3bxQ==
X-Gm-Message-State: APjAAAVaN8kQnXcrDYUa9gks3XLiJwMz37II6eBcXorDFrsSZXbk6YEk
	KFUzs+swdStvnKaukMOIbnlhMDdxjVE61mtwdiKfgZi+lQS25NGCAn790yGBuZ8rYT9zH534dzX
	D7bAXudUVLTSjiyDTMJGdfRkbhdLG7W4KuK5dvG9x8A4VFtoNqMKEF94V60uxxWUMug==
X-Received: by 2002:a50:b1e1:: with SMTP id n30mr23282972edd.177.1560305271380;
        Tue, 11 Jun 2019 19:07:51 -0700 (PDT)
X-Received: by 2002:a50:b1e1:: with SMTP id n30mr23282903edd.177.1560305270583;
        Tue, 11 Jun 2019 19:07:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560305270; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAMK5zj+M9GtJH3f9bh8KPK0awOV5pOGhJMCyqRGex/g57qQyNY7kzCle1h2IsMexi
         opgrz2KIwLlu0nKVEZ4go1P2/uR2vEOVQ4qDFWt5g5bQRACouOyUM1Q+sWEqgNibsaYz
         wX3Q8xrTueuYR5fazQBHlKK/6F/wMRc3x7G88491ZTPPsjoradcUClNx08B+YniAP+8A
         td6gdlYXf7ouiRy4TcB+p3Z2Qa+AIJvci2CNxobJAJOpMpF+23nJtKNF25uRZM1M2acw
         Oncffn32C+VR50OY4NVYOxKFiDjUjzT/SOCJgjFyzYMPSV0ET9B3wcFYudotOuKF49ri
         jw/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=e3TEzE60VRj/MS8YEEehOOQckYotYtM00jSjKCi8/jI=;
        b=iNEVwPmoERak3L+csgP2+CGRfez1EbUzix9FlUBYVCv1H8sBA2HLFmFZhoz+VKr/12
         9od/PJdDjpbHdv7gU1Ol0KcUCT+tMfj6rIy7Fl55NTDQ0ixCScqRVgu+jRs2ulk7WvEi
         64yiLB2GfjCSFMrUEJYhrbI9hhyQiCZlufeICx7B9rJCWl689xbqfrCaI8ysAWHQxoAr
         kndPY0SM13OMTNtcZZpchBUeSMTRpAFwl5rQ1ERtSjPwAqYWAHL1Wd1WTwjsToN/zcUY
         p5HLykwwzr3PyvGe0Tklox8nxilizlaESmh/FVPQCHxW8amlQZffC/Ty2Rb1MZuiLybu
         eWKg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=MTtnxOj8;
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w1sor4736716ejf.54.2019.06.11.19.07.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 19:07:50 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=MTtnxOj8;
       spf=neutral (google.com: 209.85.220.41 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=e3TEzE60VRj/MS8YEEehOOQckYotYtM00jSjKCi8/jI=;
        b=MTtnxOj8b/+TTYuM6NNkobIsRNOElKsc/8BqXi3Y/+dNGP7+MZ2IGVtBb9IvQn+OsO
         vW74urYy7EzW8nl+nFudq/JabGlvyX3vo/5Hnrim+qNbyvWWoh95wiXSZNopPL+oXF/O
         eD2Pnlv4mFpK9NfsXHt421c7OE1+1LjF2t546fw5c+ALo6qKpb5Up3nS2VgDyXsEYmXu
         0EFS1eXIH10mQztjtBB9u+208ddm8dhgPx+iDuc40U2BU6O0uLBWML0c78uHFi1gvuAk
         cpkYbNvZV5mNIS/64Z1tTp9WdsscxLL6ysWN85wbls6CM1baoMoKiseSgh4yK5TDDiHE
         ByZw==
X-Google-Smtp-Source: APXvYqz0F/coC3G7qHRNAuBkWxFLoYTo3WBL7aSNleJKw+ls654OvYPBn0myZDv5kyjEpbjibAS9FA==
X-Received: by 2002:a17:906:7d4e:: with SMTP id l14mr19826791ejp.188.1560305270074;
        Tue, 11 Jun 2019 19:07:50 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id v18sm3176634edq.80.2019.06.11.19.07.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 19:07:49 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id ECA1F10081B; Wed, 12 Jun 2019 05:07:49 +0300 (+03)
Date: Wed, 12 Jun 2019 05:07:49 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Larry Bassel <larry.bassel@oracle.com>
Cc: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org
Subject: Re: [PATCH, RFC 2/2] Implement sharing/unsharing of PMDs for FS/DAX
Message-ID: <20190612020749.sjpuquzxrprkalfy@box>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
 <1557417933-15701-3-git-send-email-larry.bassel@oracle.com>
 <20190514130147.2pk2xx32aiomm57b@box>
 <20190524160711.GF19025@ubuette>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524160711.GF19025@ubuette>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 09:07:11AM -0700, Larry Bassel wrote:
> Again, I don't think this can happen in DAX. The only sharing allowed
> is for FS/DAX/2MiB pagesize.

Hm. I still don't follow. How do you guarantee that DAX actually allocated
continues space for the file on backing storage and you can map it with
PMD page? I believe you don't have such guarantee.


-- 
 Kirill A. Shutemov


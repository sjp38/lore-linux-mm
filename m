Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2A8BC004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 15:09:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94C96205ED
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 15:09:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FfrRoNiW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94C96205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D7596B0005; Tue,  7 May 2019 11:09:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 287E86B0006; Tue,  7 May 2019 11:09:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 129976B0007; Tue,  7 May 2019 11:09:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id E6E316B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 11:09:57 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id v13so1842296oie.12
        for <linux-mm@kvack.org>; Tue, 07 May 2019 08:09:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7B0YY/tuwYgSrVIfUPS1cgz9LxSrbQPkHLz8B/p2y2k=;
        b=AYxYQ3n0VIYV9du+vA/bizt6uJ6yz3iSo857Sft3nvEbJBj4FmeGMODfq60Ztq7k0V
         lsEod1QDZW9DQj1ih6t+FBnUgAoUhBIxiXdyH0zLmj8LNw8HAyKn4YkxhIiyc6C7ogU5
         jC/ctlzYEMldOCpj2OiXEszxb+LFiOyA4AnpJlFM1Fptj8mlxbQZroqBYSSXtiaY6+dN
         noU9aJkH1j6tyo8mkYi6OSXlahPNjTilI2Fkq5zChgQKdg/rLSt7VKMmjIHBCPESdLkz
         m3oXDk5wwnJiAne2+WzpCeh7SJw/XkmVhxwezwrKJPAEy3P36Q5y1JGc1JimIqCTrtch
         YSaA==
X-Gm-Message-State: APjAAAVSET7P8BRZjzdILX1XSHNv7vEY3JxbA8qgtv/LvvDWOQgYXDlc
	tH0R6rz6JvBRf0TStOOqZx+eLKFSCWdKmhdrlBLgnPR0O5ru7by8AkpUz/yTzGHVjJxNS+f7rWq
	iAJJaWAVPO7yWJmY6fmaKLGZI0WNSN4Pzw5+4IgwdjejmaVUS2ybu5zj58K7aIXd0Yg==
X-Received: by 2002:a05:6830:1246:: with SMTP id s6mr3046436otp.8.1557241797619;
        Tue, 07 May 2019 08:09:57 -0700 (PDT)
X-Received: by 2002:a05:6830:1246:: with SMTP id s6mr3046359otp.8.1557241796679;
        Tue, 07 May 2019 08:09:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557241796; cv=none;
        d=google.com; s=arc-20160816;
        b=WCO7+dNSax/4nElCmyhyoCG4Nxp2eWx3DzsF75FYfVW/VznhTnicJVOpUFN/Y/PtDF
         7nvII0MrckYVGXm7EQ5LObbTJrmLUX+3Ube6bCQ211HiGNEIyHXoD3TifNMgCJYD/sDq
         3X1muvmKgeHShsKw3CPfBzjtM89WaHVu8w2f2ELwzKplcLdNNl9Ke9F6wVkqCx/dhN1H
         myamtpDSRnYiFdK80WtxbD4b2S8XWKTGb/sDufTcLyDTZwus+/dMiVDhs6AkvIc0JQpL
         8tzE/76UF+3Miynd4EbZLbbkA25n3yljImEKjha4Oj7aDtQ5rY/R75lfQqasmWGmtr4y
         /12A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7B0YY/tuwYgSrVIfUPS1cgz9LxSrbQPkHLz8B/p2y2k=;
        b=NMK7hdfubQ86p7BvPb+pUVjFdmM3b87A1s3RdzODcZjHknylKioI6KHHXoBM2dqu3r
         AulFO0Pty8DsmZaUyo9AUoMF39gkOrToDzyC6/sYdj/Zp+ZI7ccuJHb9djZZzpjJFipD
         l1hqzAaNfRP3OoQ9DeGsH/L8jf32lLVGXKDjOC7nWZ9rjasbY17SXtUkiNMl9MuHS0Ms
         N1kOtwxZSY8UQDt/H87uz+luT+g47EJU2CGK+IJ0sf/CovoKNgRH2Z7nowFdRiQlSqxw
         WSHuCHBx2c4FICBinbelbgPtV04tcJTIQkfBlNKM6zUqL2IQvR0OAHKE6gpzg7RtIOLd
         EvlQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FfrRoNiW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor5689572otn.143.2019.05.07.08.09.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 08:09:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FfrRoNiW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7B0YY/tuwYgSrVIfUPS1cgz9LxSrbQPkHLz8B/p2y2k=;
        b=FfrRoNiW2mqPyRdm+Nc6T26ie1KUmZiB8g8NJpOEz+itth0sQuL/nCF/kQjKsdZkul
         PXSf4dULc+bFlcloKFVfMNq3RbFquJOLQEcSHhKjpodw03sRBfMddCY4qkMAQfR44OdX
         DITETRUBDe82rvbvHBxX/uAdT759KWoE8SBZh5Xq1XsEIRFyhnV/soh4jaPoMqnYHG2D
         3f3YNfo+BwBRIqOCn55ArQt6m/JOGYKZLcKidrS4fzIbucvP+yFSdd2gQC5XIyiQbRox
         PQEMSgyvWjS5m4dT9pbbNU+mf3C8DXxgJPh94oqQQKCSBDudx+SvPKXfsIGSY0BENgk0
         VXzA==
X-Google-Smtp-Source: APXvYqzbDPGe8upi/eqDgtg9Nkitw8XKPSXhVZF9UexfGpCo0Vyt40wC/xRq29IX5XuEtHL2HlKBUOKn8giE61p9obk=
X-Received: by 2002:a9d:6a96:: with SMTP id l22mr13049733otq.98.1557241796269;
 Tue, 07 May 2019 08:09:56 -0700 (PDT)
MIME-Version: 1.0
References: <20190401051421.17878-1-aneesh.kumar@linux.ibm.com> <87pnoumql8.fsf@linux.ibm.com>
In-Reply-To: <87pnoumql8.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 7 May 2019 08:09:45 -0700
Message-ID: <CAPcyv4go1Ya=D-8O2JjecRA4GRDH1PdhntzjaxhYUQa+-srLiQ@mail.gmail.com>
Subject: Re: [PATCH v2] drivers/dax: Allow to include DEV_DAX_PMEM as builtin
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, Linux MM <linux-mm@kvack.org>, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 4:50 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
>
> Hi Dan,
>
> "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com> writes:
>
> > This move the dependency to DEV_DAX_PMEM_COMPAT such that only
> > if DEV_DAX_PMEM is built as module we can allow the compat support.
> >
> > This allows to test the new code easily in a emulation setup where we
> > often build things without module support.
> >
> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
>
> Any update on this. Can we merge this?

Applied for the v5.2 pull request.


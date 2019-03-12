Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06724C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:35:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 980D32084F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 03:35:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="a+P5awS+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 980D32084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB2AA8E0003; Mon, 11 Mar 2019 23:35:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E62778E0002; Mon, 11 Mar 2019 23:35:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D51428E0003; Mon, 11 Mar 2019 23:35:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9FFAB8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 23:35:19 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id i4so545299otf.3
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:35:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=HV9Xo5Ma6lVYXnnefOkN3s7QC0UD+0lVGEF+kVfiIRk=;
        b=oeynOMADsRV8aB8eV2H4LdFCBiDqBEFCrqtzq+CEWWnGuNl+Iwmj0Y4sSTtyV5l2zL
         tivboD07J4dLeb1/pJ3c8MteUBv9qeuBaXi0LBoaoWMerKW5jXO6mdkhKv1kmTmEs5n8
         KJ52glNwq/4x+4MEX2+NIcSgk3/ySGprVs+lTGUyZ1h6JVttF/Tbq5eZijw8TdfYq+/2
         L5ddoqYHgGvx//+pILrbu7UNzg8xjdI9ngbcMygYcFOt5QfadSS7fa04ZCBVUQ0/ac5+
         1xHkD7TYSEGuDpBa6QVfr2LQpW3Lctcflz21mzo/iu1MgjGCZdSw8OHt7AI+e7cUwoov
         w9OQ==
X-Gm-Message-State: APjAAAUgMKB4wgOKThIpzz0m9DjtSCwAzT6aQE0ebuvskU56d277m4lc
	CsKpdPO664GHEUkNbhzI09qsgojODm/srjV6jAXdndz549R4Zn2cvbwLXjmw9mE30rVMA+pwxOt
	drzzXjTQuYO/x/1YGdAjhxWvzamNONb1Qy3g4x4PQsp9bNAdcf4tWNkMWE2FtINUXePv0dl22in
	SUrPRM930dG/vaOEGZp3ddNTBe0M6RDnboopXTlEXlVGxt7HuC4VeBnfCjmCOh+hdO8I+KPYv3M
	tvvfrNsNrLB7XN+o398qL2I6keU7rWVbO5xVH7cphzWlzBS0YRJrzW/juAcCXS+gXkG7ZwRDMO8
	UJHogz31FiV8ZXIpEgGgqYCJXuUw9l5w+LkTszyKAShXnWlDsDwLrTJvR7EV/A52UYngVTuo5S6
	4
X-Received: by 2002:aca:5450:: with SMTP id i77mr400974oib.174.1552361719221;
        Mon, 11 Mar 2019 20:35:19 -0700 (PDT)
X-Received: by 2002:aca:5450:: with SMTP id i77mr400949oib.174.1552361718332;
        Mon, 11 Mar 2019 20:35:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552361718; cv=none;
        d=google.com; s=arc-20160816;
        b=ABOKNn++WCtqPyaDPuE2NipNIcNN2HvyiJSqftqs7vd9nC5F2UN0U5aMU1eFle+V3F
         tEysT/am0hA5ULSIbzRDwBeq+Z0PN/JwV7s2idL5ubG3jxQJmjjDwHkIhOejIsMNO51h
         8JGtf+9DhkvmdmIcujrnSiWpVFHSPXC+112TAMtBa7z5QC7qPEJbWvtUfINIpj+BUugr
         8OlZmL/okx7wHdhz+PCXt4TsadqIJbrqdqTMsDU3/hxfZiYFqGlOmfM1PnfRkD6oQ73Q
         yBp/Sl0k+1+wNLPylwEu16BE26EbMXWWXcwu+vTBoSHnRACxzHpLU529CXwa0vef++bI
         AwNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=HV9Xo5Ma6lVYXnnefOkN3s7QC0UD+0lVGEF+kVfiIRk=;
        b=SBNay4r2Pjjvx/jXrYIMtXRffxY9EVU6yRPlkWysvgJH0zefCyVeTGAE2nMn84UlFR
         PQdrcEZNJ8SUbvyeTBH382Uf99EKT5xxGS7ZU/gwE5qJiUyRi0c7S7d827zIAdM+qvou
         XbYMpBX784tFFOy3HZfg8ENbSXc5Z1gWZEMrAFCGZXJQ85Ht+cg+Hx0WE2nDpICW1kHQ
         VogxBGliUFTaFgQVLabo3y+15wZBTU3VQrc5mQjbTsr8s/Q/d0pF2Ew7gCmHiIjTXgZP
         KsPc84Ig1suG0bHJhambEzId3RNnp4agQ52AnbkxoT1zNOp4Ur5263Ep2AdZqQWxxxng
         CigQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=a+P5awS+;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m13sor4042570otn.97.2019.03.11.20.35.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 20:35:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=a+P5awS+;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=HV9Xo5Ma6lVYXnnefOkN3s7QC0UD+0lVGEF+kVfiIRk=;
        b=a+P5awS+rHv8SYzpZkCKu06tF99ysSWmtYV0NVebAMMHSOrnd69FxXz5cDXGXcTnNk
         Hqi4YJkOQDtFQKiC1IZYDviCQADNHx/H+lniP5PaNMrMIGwyP2Om2T52GGZLx+vuu3n7
         VABvZk/Cu0B+gegCvVBhAy2hBpwRVEviEPbOivYhVFFnetsaobRzBkN+TLNUHE/Wgke5
         1HIrT1YcrSEXFf2cAPx9jFR8UyMAfVTz683Mxya9JX7x08iPRdkxqQUhNEBuTysZ0MlB
         Oz4eE9TN1Y1JGr/Zjde9K+rdQQat+A7WN1bd7X8rsoQ9makNrLnvWiBIoIFkty8Fxg0A
         w8Gw==
X-Google-Smtp-Source: APXvYqz3+xhcwjCTABnnnXaqWa211tTYNu9X+gsXADebkmDMCPT6c+SVz0UNy13y3/3bWz3gOG4LDoLrrfuMon9I190=
X-Received: by 2002:a9d:4c85:: with SMTP id m5mr22472717otf.367.1552361716668;
 Mon, 11 Mar 2019 20:35:16 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4hwHpX-MkUEqxwdTj7wCCZCN4RV-L4jsnuwLGyL_UEG4A@mail.gmail.com>
 <20190311150947.GD19508@bombadil.infradead.org>
In-Reply-To: <20190311150947.GD19508@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Mar 2019 20:35:05 -0700
Message-ID: <CAPcyv4jG5r2LOesxSx+Mdf+L_gQWqnhk+gKZyKAAPTHy1Drvqw@mail.gmail.com>
Subject: Re: Hang / zombie process from Xarray page-fault conversion (bisected)
To: Matthew Wilcox <willy@infradead.org>
Cc: Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Barror, Robert" <robert.barror@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 8:10 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Mar 07, 2019 at 10:16:17PM -0800, Dan Williams wrote:
> > Hi Willy,
> >
> > We're seeing a case where RocksDB hangs and becomes defunct when
> > trying to kill the process. v4.19 succeeds and v4.20 fails. Robert was
> > able to bisect this to commit b15cd800682f "dax: Convert page fault
> > handlers to XArray".
> >
> > I see some direct usage of xa_index and wonder if there are some more
> > pmd fixups to do?
> >
> > Other thoughts?
>
> I don't see why killing a process would have much to do with PMD
> misalignment.  The symptoms (hanging on a signal) smell much more like
> leaving a locked entry in the tree.  Is this easy to reproduce?  Can you
> get /proc/$pid/stack for a hung task?

It's fairly easy to reproduce, I'll see if I can package up all the
dependencies into something that fails in a VM.

It's limited to xfs, no failure on ext4 to date.

The hung process appears to be:

     kworker/53:1-xfs-sync/pmem0

...and then the rest of the database processes grind to a halt from there.

Robert was kind enough to capture /proc/$pid/stack, but nothing interesting:

[<0>] worker_thread+0xb2/0x380
[<0>] kthread+0x112/0x130
[<0>] ret_from_fork+0x1f/0x40
[<0>] 0xffffffffffffffff


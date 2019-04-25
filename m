Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2AE5EC43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 18:51:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 728842077C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 18:51:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="H7Bd7bG1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 728842077C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E8216B0003; Thu, 25 Apr 2019 14:51:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 497BE6B0005; Thu, 25 Apr 2019 14:51:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 387ED6B0006; Thu, 25 Apr 2019 14:51:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE1546B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:51:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u16so218904edq.18
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 11:51:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=b55P2IFv2UpxlgvURrxCcFTUbkVb37FoCTfo/TcEgTE=;
        b=K2IlbHI+rOumu/9TibMG/IWBsEnP3GF8PbDCbzjotO4RNxoN3TJfWDa10/lAd/00qc
         5ProV1EYlpHDB5ewCOWM5qgchHdAeIdctyeZWf+e/VIEbzM3MHApDajELNYjN4LStWp5
         WkpArXStauHxkmwV231loxbimSdFDkGPQD7BUe6ja2y3d+RusauL++73Lh7Y6KIz68PX
         pCBDy/TodcCN4Cczavng6XHdQutqwyhxWhmM92SyHvlRrXA2Xlr/0wjxNYfUu93+lAtC
         4+vH1+8IMtqFUWgaNA4c36jBjt5dcVfittvr5cSmMOBPBXCycSB5r2gj3K1jt5uYeUkb
         Bnuw==
X-Gm-Message-State: APjAAAXCCdovGVJxRLhlhPF964B6LSWwLvNNLqtRDfDTSCCYvHzFaqIM
	66vX+dYzdxlyzg1iT4W2MDkwKn9+yYIq3H1eMqYvmBiovFzxw42FSZAitTnkt4zmeYtEMks8HWm
	5bTi6CIVPPh8457B2SPqlUpHdh3El5KsbYD9dCZuAM/L275BegS3v6fyBlNPPse/oHg==
X-Received: by 2002:a50:ce45:: with SMTP id k5mr17451159edj.202.1556218309390;
        Thu, 25 Apr 2019 11:51:49 -0700 (PDT)
X-Received: by 2002:a50:ce45:: with SMTP id k5mr17451100edj.202.1556218308187;
        Thu, 25 Apr 2019 11:51:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556218308; cv=none;
        d=google.com; s=arc-20160816;
        b=Bohi59GcONtkbS77hE7cw2l9y1SBbkrGuYGOsh2chcm+vNXQ5Se+5PsreBZMAC/5j1
         TIwFGOImyJCaQ7ACpRc7+NrhJ6+T1FPgrHuWZAoOo8NSQyOoaW06kLnb7fOIwdR32Lqo
         4gvdi+hKHqQGk4aVYcsVuqfzpueK94NJZeWcWg6GKsEejLuENxl80cIRYM0LclL9hcvr
         1c16+oMVeshWisjP/6PcGTk3RToetoiPRUl3NXM0v7f2sW0JobRdkyCbgwOUAOWcF5CB
         ceKk5GaENzA40WPsxu1RY71vd86sFy0yOzyJu6kF5RU9ZwfCq4+Wn6FX+pe0f+bWWJqF
         +QSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=b55P2IFv2UpxlgvURrxCcFTUbkVb37FoCTfo/TcEgTE=;
        b=CakkqX4M7ZSnhWlScTv6ycPQN5tJQteEFIcq737qTXH406EqCv2/a7dsX7cjP5bmyc
         65f36VkIlLwIyJDcweFS39MBRkVhGIs76cLeeAMPk6UHsr1h52mMCMJ872jveVLzrPUt
         rnctbTccHBKyMd9YKimLt2YprCBwmha9qtd/Ksw4+Y1s2mbE+cTSNTGBpXfEW5JRMv0z
         LozNr+oI399dV2ORDMVQr//srfE6pRCGCNBGkwm3WjpndIWzNshkyUgV7hesFAOq+vYR
         Htq+QAjPVhfAZF00yObTjPzKS1ErK5vBMG/eQVt9I29RdOpUR+LZ8OLy4tmQzJqsd7bA
         jrYg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=H7Bd7bG1;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v22sor7727180edc.13.2019.04.25.11.51.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Apr 2019 11:51:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=H7Bd7bG1;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=b55P2IFv2UpxlgvURrxCcFTUbkVb37FoCTfo/TcEgTE=;
        b=H7Bd7bG1fJeV3A7INUqsw/yC6Tcx2LmSaWfrxZGHChZtX9HVJ7LWkiMwAStQzY1A6C
         e24kQ8YYbrhBrBPegRC0b9Le06WH/iz/3/Tb9vPHtsQSfj/7EC6gZ+JFDVIQQAlBndJo
         NIJQBoajtzB8lRybkTxj5S/QajeNkN6FOkAIsnrct7YcTs9idIKsQd2EZD0LinOY1wPR
         ketwMV/wqOn8l22PoVtns2mz+U6LYkCkn02WCKWghRaCrl1nL+81/ToLl4nmbcTdxoLN
         /medWc+TUcgxQAQvDM7+8Vz9OFaSYGcHjgAa1VBRCMiEYYOVhIQ+mOykud+6mW8u+/SI
         yPVQ==
X-Google-Smtp-Source: APXvYqxfNCds1kl6313Ad4+cJxM/dXtmhN6kZ83GGVN0OsY6b4YD/uFBtltwpNCLN5C76jVxd/HWZ8/Eth051yXAoBU=
X-Received: by 2002:aa7:cf8f:: with SMTP id z15mr22750446edx.190.1556218307805;
 Thu, 25 Apr 2019 11:51:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190425175440.9354-1-pasha.tatashin@soleen.com>
 <20190425175440.9354-2-pasha.tatashin@soleen.com> <67dba1e2-155c-f572-81dd-a6d589d0e8a5@intel.com>
In-Reply-To: <67dba1e2-155c-f572-81dd-a6d589d0e8a5@intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 25 Apr 2019 14:51:37 -0400
Message-ID: <CA+CK2bC5G0DrBpHuaV5xrAAZUKHVwN2N++eiV++SH2gvvbKGHA@mail.gmail.com>
Subject: Re: [v3 1/2] device-dax: fix memory and resource leak if hotplug fails
To: Dave Hansen <dave.hansen@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 2:32 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 4/25/19 10:54 AM, Pavel Tatashin wrote:
> >       rc = add_memory(numa_node, new_res->start, resource_size(new_res));
> > -     if (rc)
> > +     if (rc) {
> > +             release_resource(new_res);
> > +             kfree(new_res);
> >               return rc;
> > +     }
>
> Looks good to me:
>
> Reviewed-by: Dave Hansen <dave.hansen@intel.com>

Thank you Dave.

Pasha


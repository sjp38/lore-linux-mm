Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56055C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:44:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F0442082F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 23:44:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F0442082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B22696B0006; Thu, 28 Mar 2019 19:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD1F76B0007; Thu, 28 Mar 2019 19:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 999B46B0008; Thu, 28 Mar 2019 19:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7A5B36B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 19:44:05 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l26so519032qtk.18
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 16:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=7gO3MgRIHA45O7FBHQsl0S/71stlU6HO9z9NnYKnAu0=;
        b=ZDBnaOpr3dB+SoCD8147pryJ0IEhwzcC4Qh/zap1uNt7NzIdHB/xeLCC7YDWZthAtA
         IFkrzPbIMOrHcMTy2T6jHk5KzjFQmVRSXQHuK85QtsGSRZKiscTj5BcWiD3nfHMR2XVZ
         0TeUtCQtNWp46QoJojUjKCiYLtH3bGbe4Tk+qCSzp9GV5wbcwRIIecaRkBrdmqC2WS/b
         uUsz26oUlVuuYWgwIbVj2c6J5v2LSsBFiITEsgSif0R9qfO/1fdUfj4nNE2xIAFnZtN1
         uLLlCd2gdPLh4YfCuI8wWWyedzsH4uLrohCIuRruq8THSkfCJJ4BF2osiN7DE5Os7PWA
         0O0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWXINi5Hrg8lfzuxZWKcvAauZathfMqEXUYOs7qI/71zRUV5TY1
	iEw/ZrJjgsiWc3sFNekCrOoDLxyvm5A8qmetI87Jg/zFQh9/vqcJBlQ+jYoVQIDX2WQz9rGFD9f
	Nu+95CBXe/zp0EPAitnHn6hMipFjc0JuVfwIOPVahWJRyxNbmhuR7yg8+KxpxNrZcXA==
X-Received: by 2002:ac8:30a1:: with SMTP id v30mr37443454qta.176.1553816645193;
        Thu, 28 Mar 2019 16:44:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6Xg6T35pCfIpz1u9hV9S+XeYsgEyatQnMOXyNjoltSUAJFaFjKSKzJs77he8Ju+f2KzCD
X-Received: by 2002:ac8:30a1:: with SMTP id v30mr37443414qta.176.1553816644337;
        Thu, 28 Mar 2019 16:44:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553816644; cv=none;
        d=google.com; s=arc-20160816;
        b=WBlI/tlrxbfiq4uc5gzZPIuWPlZPMoJhuWuFCuRIDylzUYC+AxRqEce+kQb1DfUh6D
         SbQylz91Z+rnXN7stRcvIuOUNudM2ocpvp0+k/fP+OMbLiYAXtysNCO1cw7zTJlyqRbL
         HaPt0Z8KQL1FoZorvNH1+0z5MaQarkerMQSET0rMoAoZkXEway+Nt4PQXDC8QxE7SeRL
         lPEgMzGj5s+P/rVjHhNsUA/omQax26u4TSUTg4p86+wTLDKcsgUVdK5lYUpQ1ylsWf4D
         fcQNzlMoxeiwsIzcCRHg5Dh04Sw2sxfWZ7Os7olxR0l6JmjnDLboIMvmOeOmf9xQLRan
         8nPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=7gO3MgRIHA45O7FBHQsl0S/71stlU6HO9z9NnYKnAu0=;
        b=D4pIrWbqScgj2zooeiy4UCfwm7F9L02uuutuhbbtV6uVRM4AhhLCYAhKLECrUPGUuP
         pbSQadcxP9/ro+p/H/+vweM54CsErkar/rD98k5CQ5ijOARzaBNkMnRCzUgkevzldn4d
         snoB8mW3xcuwAgMbcjEDW11+u68onbRbzk4pj9RjFcJ5TIAfteZBjzWqk1FxntbuwE1u
         F6tqVze6gLjfSoYcYJ0RVl5WmYxXwU+1O3ZXIIbVV0rYrHjtwywwAeM3lHZLpqHuafPs
         /TcvPotOgmvgjsMJOJ/T4WSMGedx4CXGnZkWq69bq45GLPHuVJjrqzE1rSfwpXButQMt
         1bhA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v19si250985qtq.190.2019.03.28.16.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 16:44:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3DB9B88AD5;
	Thu, 28 Mar 2019 23:44:03 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 18379183D5;
	Thu, 28 Mar 2019 23:44:00 +0000 (UTC)
Date: Thu, 28 Mar 2019 19:43:58 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 07/11] mm/hmm: add default fault flags to avoid the
 need to pre-fill pfns arrays.
Message-ID: <20190328234357.GL13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-8-jglisse@redhat.com>
 <2f790427-ea87-b41e-b386-820ccdb7dd38@nvidia.com>
 <20190328221203.GF13560@redhat.com>
 <555ad864-d1f9-f513-9666-0d3d05dbb85d@nvidia.com>
 <20190328223153.GG13560@redhat.com>
 <768f56f5-8019-06df-2c5a-b4187deaac59@nvidia.com>
 <20190328232125.GJ13560@redhat.com>
 <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d2008b88-962f-b7b4-8351-9e1df95ea2cc@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 28 Mar 2019 23:44:03 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 04:28:47PM -0700, John Hubbard wrote:
> On 3/28/19 4:21 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 03:40:42PM -0700, John Hubbard wrote:
> >> On 3/28/19 3:31 PM, Jerome Glisse wrote:
> >>> On Thu, Mar 28, 2019 at 03:19:06PM -0700, John Hubbard wrote:
> >>>> On 3/28/19 3:12 PM, Jerome Glisse wrote:
> >>>>> On Thu, Mar 28, 2019 at 02:59:50PM -0700, John Hubbard wrote:
> >>>>>> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>>>>>> From: Jérôme Glisse <jglisse@redhat.com>
> [...]
> >> Hi Jerome,
> >>
> >> I think you're talking about flags, but I'm talking about the mask. The 
> >> above link doesn't appear to use the pfn_flags_mask, and the default_flags 
> >> that it uses are still in the same lower 3 bits:
> >>
> >> +static uint64_t odp_hmm_flags[HMM_PFN_FLAG_MAX] = {
> >> +	ODP_READ_BIT,	/* HMM_PFN_VALID */
> >> +	ODP_WRITE_BIT,	/* HMM_PFN_WRITE */
> >> +	ODP_DEVICE_BIT,	/* HMM_PFN_DEVICE_PRIVATE */
> >> +};
> >>
> >> So I still don't see why we need the flexibility of a full 0xFFFFFFFFFFFFFFFF
> >> mask, that is *also* runtime changeable. 
> > 
> > So the pfn array is using a device driver specific format and we have
> > no idea nor do we need to know where the valid, write, ... bit are in
> > that format. Those bits can be in the top 60 bits like 63, 62, 61, ...
> > we do not care. They are device with bit at the top and for those you
> > need a mask that allows you to mask out those bits or not depending on
> > what the user want to do.
> > 
> > The mask here is against an _unknown_ (from HMM POV) format. So we can
> > not presume where the bits will be and thus we can not presume what a
> > proper mask is.
> > 
> > So that's why a full unsigned long mask is use here.
> > 
> > Maybe an example will help let say the device flag are:
> >     VALID (1 << 63)
> >     WRITE (1 << 62)
> > 
> > Now let say that device wants to fault with at least read a range
> > it does set:
> >     range->default_flags = (1 << 63)
> >     range->pfn_flags_mask = 0;
> > 
> > This will fill fault all page in the range with at least read
> > permission.
> > 
> > Now let say it wants to do the same except for one page in the range
> > for which its want to have write. Now driver set:
> >     range->default_flags = (1 << 63);
> >     range->pfn_flags_mask = (1 << 62);
> >     range->pfns[index_of_write] = (1 << 62);
> > 
> > With this HMM will fault in all page with at least read (ie valid)
> > and for the address: range->start + index_of_write << PAGE_SHIFT it
> > will fault with write permission ie if the CPU pte does not have
> > write permission set then handle_mm_fault() will be call asking for
> > write permission.
> > 
> > 
> > Note that in the above HMM will populate the pfns array with write
> > permission for any entry that have write permission within the CPU
> > pte ie the default_flags and pfn_flags_mask is only the minimun
> > requirement but HMM always returns all the flag that are set in the
> > CPU pte.
> > 
> > 
> > Now let say you are an "old" driver like nouveau upstream, then it
> > means that you are setting each individual entry within range->pfns
> > with the exact flags you want for each address hence here what you
> > want is:
> >     range->default_flags = 0;
> >     range->pfn_flags_mask = -1UL;
> > 
> > So that what we do is (for each entry):
> >     (range->pfns[index] & range->pfn_flags_mask) | range->default_flags
> > and we end up with the flags that were set by the driver for each of
> > the individual range->pfns entries.
> > 
> > 
> > Does this help ?
> > 
> 
> Yes, the key point for me was that this is an entirely device driver specific
> format. OK. But then we have HMM setting it. So a comment to the effect that
> this is device-specific might be nice, but I'll leave that up to you whether
> it is useful.

The code you were pointing at is temporary ie once this get merge that code
will get remove in release N+2 ie merge code in N, update nouveau in N+1 and
remove this temporary code in N+2

When updating HMM API it is easier to stage API update over release like that
so there is no need to synchronize accross multiple tree (mm, drm, rdma, ...)

> Either way, you can add:
> 
> 	Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> 
> thanks,
> -- 
> John Hubbard
> NVIDIA


Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 27F5DC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:50:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBA50217F4
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 17:50:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="bgbHJGPT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBA50217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FCC96B0003; Thu,  8 Aug 2019 13:50:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 586D16B0006; Thu,  8 Aug 2019 13:50:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4021C6B0007; Thu,  8 Aug 2019 13:50:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id CA3C86B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 13:50:57 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id z14so11517298lfq.21
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:50:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=PaqvtAtk6zixEgRbfRi83KAjX0fbzFPUrAlK05McGqs=;
        b=TX54Wavez6tBOsh2qCNkwYd+HZdoUVcYTKIFnx7tOBJJq32zktx2HTIzFMfLz/EQ9e
         rqezAOWCB5tqpvxwThFaZIMEMnfRpJe3IyFTTTxIyMQzI9qpu6I3jftST7QK8iKJ/N1t
         Mwr/QzZzVJKI6yNxW1ZjA0vC9jEqzpjnAfFEVfjc/nI0iLOZDnUzugIR23wnpYkR9A7z
         lXI6+wfs2oT4Wx1o54ag2cQHPC142oVhqtc1+2zfM5ZEfHZFuulxnwDfTu3sU7PkwSq8
         +DWadwHli54E/ceMLE2Qk+7cnaHmxxVtpA4+scYFBdDd1ZPjCEI0Zhdu6TC7jemcowBI
         Sgyw==
X-Gm-Message-State: APjAAAV9KMoG6fl1EBWGeS0Tge4A5Llm1jV0+2Kldu61KeNz+Mc/ZH15
	2lFL+vY9gM8QyWBhDTIr9nNcgXEc3GRcov7Tj+Upth5B+6/z+R76sJVAgY4Up5IG9l3e7wDEZ6/
	qno6oqo26HPhNeWBsZKetT17NVPQismt4mZg9paex4BvvrmyT2XH3xz1F2pF4Zop0qg==
X-Received: by 2002:ac2:46f8:: with SMTP id q24mr10212127lfo.89.1565286657017;
        Thu, 08 Aug 2019 10:50:57 -0700 (PDT)
X-Received: by 2002:ac2:46f8:: with SMTP id q24mr10212099lfo.89.1565286656287;
        Thu, 08 Aug 2019 10:50:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565286656; cv=none;
        d=google.com; s=arc-20160816;
        b=U9Ajh9/MYNNND+pjspPZfrhPUqfZ5h/c2ifalbMRppT24PfO/OHm8F3AlBPhXCftHB
         P2KqdYNMJawRd7WA4zBcetAUIrETOaZj5jNvcuXme0YHE8zwkpPIATqeYQbd7vCrPkWd
         14fBNnwsOwisCC/gSoEwepqV+LXo0Oq1PmqvaO0VJSDfdl9+VXCWTsFJeibACZUPB1l2
         6UyFa9NBj9A7X224E7bDrRu3sVltzWp0d/qD+3xLs2ScXl7yt6TWnpHbyJ92BP5dNMGh
         wwyYwk9nDI9fOG7Duf1WjBsDLWHjryJbfziGRRddv2q3ExFO+lIGRgYINc4WKpzpBZKp
         tRog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=PaqvtAtk6zixEgRbfRi83KAjX0fbzFPUrAlK05McGqs=;
        b=fj22nrYN3XikrFkh5ZNp5vHsSONufQG1rwBRHJBFy0JvzOaTV/hEpSbcHDqxE4mJyM
         vm86GbZaR1snXYAcaD71ohwXEf1lJyG+FY8gBYT/+Yyl6qFv4/lmCIDnvujGRnRhq3jF
         qR35WGHSkrGAKzu9+ZITsVpQpPYGwgyXQTLV/N4wjAiOy18SxGZ3AwgNQ9pjA6D2hSuU
         Xx/6EYdQ1xLjcWOvOpOvLPf1SuyrH2w2xHhwC8bXSjLHWOOiPtcd413BQ6tVPs7LT9zn
         ytGegP0ogtG2Py2Gr/uqFhDvcJNR1MzKMjV/w5Dr8hBbDFZ45HFq/3yADRoYugRQA1qz
         1Dgg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bgbHJGPT;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y26sor1862944lfe.54.2019.08.08.10.50.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Aug 2019 10:50:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=bgbHJGPT;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=PaqvtAtk6zixEgRbfRi83KAjX0fbzFPUrAlK05McGqs=;
        b=bgbHJGPTR7Koz+c795LwPw5LpjTkYHSGo/WjpWK8uhqHWX4RU/bw/U9W/Ciokdadeu
         SGeRFfN9p7jgody3HoUb/XyE+F1uRIDJUun78fKUfuAUfCCMsxPiNoI47NPA99/T2Ok4
         kVZRDdHEM2k89KQ/yjYtrD7kr74Ot3DoZ7wk0=
X-Google-Smtp-Source: APXvYqwNYlSfLNEdDUY9+5DFyLy5ZPjvrIXMPZYljRt1kgLm0VfHBfs4jIBqwroCmsdEpyg3q/0JIA==
X-Received: by 2002:ac2:5314:: with SMTP id c20mr10065872lfh.1.1565286655040;
        Thu, 08 Aug 2019 10:50:55 -0700 (PDT)
Received: from mail-lf1-f49.google.com (mail-lf1-f49.google.com. [209.85.167.49])
        by smtp.gmail.com with ESMTPSA id j3sm17042351lfp.34.2019.08.08.10.50.53
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 10:50:53 -0700 (PDT)
Received: by mail-lf1-f49.google.com with SMTP id c19so67500981lfm.10
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 10:50:53 -0700 (PDT)
X-Received: by 2002:ac2:5c42:: with SMTP id s2mr10385649lfp.61.1565286653238;
 Thu, 08 Aug 2019 10:50:53 -0700 (PDT)
MIME-Version: 1.0
References: <20190808154240.9384-1-hch@lst.de>
In-Reply-To: <20190808154240.9384-1-hch@lst.de>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 8 Aug 2019 10:50:37 -0700
X-Gmail-Original-Message-ID: <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
Message-ID: <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
Subject: Re: cleanup the walk_page_range interface
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?Thomas_Hellstr=C3=B6m?= <thomas@shipmail.org>, 
	Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>, 
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 8, 2019 at 8:42 AM Christoph Hellwig <hch@lst.de> wrote:
>
> this series is based on a patch from Linus to split the callbacks
> passed to walk_page_range and walk_page_vma into a separate structure
> that can be marked const, with various cleanups from me on top.

The whole series looks good to me. Ack.

> Note that both Thomas and Steven have series touching this area pending,
> and there are a couple consumer in flux too - the hmm tree already
> conflicts with this series, and I have potential dma changes on top of
> the consumers in Thomas and Steven's series, so we'll probably need a
> git tree similar to the hmm one to synchronize these updates.

I'd be willing to just merge this now, if that helps. The conversion
is mechanical, and my only slight worry would be that at least for my
original patch I didn't build-test the (few) non-x86
architecture-specific cases. But I did end up looking at them fairly
closely  (basically using some grep/sed scripts to see that the
conversions I did matched the same patterns). And your changes look
like obvious improvements too where any mistake would have been caught
by the compiler.

So I'm not all that worried from a functionality standpoint, and if
this will help the next merge window, I'll happily pull now.

             Linus


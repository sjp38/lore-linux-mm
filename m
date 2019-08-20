Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B637C3A5A0
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 00:17:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14C8B2087E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 00:17:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="QwxNFOyZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14C8B2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linuxfoundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA3926B000D; Mon, 19 Aug 2019 20:17:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A53206B000E; Mon, 19 Aug 2019 20:17:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91AA06B0010; Mon, 19 Aug 2019 20:17:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0241.hostedemail.com [216.40.44.241])
	by kanga.kvack.org (Postfix) with ESMTP id 6931E6B000D
	for <linux-mm@kvack.org>; Mon, 19 Aug 2019 20:17:05 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 0FA46181AC9AE
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:17:05 +0000 (UTC)
X-FDA: 75840891210.08.offer57_20b0de4987616
X-HE-Tag: offer57_20b0de4987616
X-Filterd-Recvd-Size: 5658
Received: from mail-io1-f68.google.com (mail-io1-f68.google.com [209.85.166.68])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 00:17:04 +0000 (UTC)
Received: by mail-io1-f68.google.com with SMTP id z3so8366951iog.0
        for <linux-mm@kvack.org>; Mon, 19 Aug 2019 17:17:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linuxfoundation.org; s=google;
        h=subject:to:references:from:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=nTxRglECnRmEfEUbvLbhnxA1qZmKfNixmSHC78U1yvc=;
        b=QwxNFOyZUDfagOWtOAI4X8BFLGadKzOv3qoVjxv9WjdUozADcl2Ku7So3hPmLVlVk2
         7O/sfownr4XSwH2KOC21ucYh0COEAXN+aY2fbnvOt7ItZyQ6wiL/v0UeE7GvikpRKF65
         plwfDM8VOYaTixfrX8PJF2RTBIgTCKEMM8SX4=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=nTxRglECnRmEfEUbvLbhnxA1qZmKfNixmSHC78U1yvc=;
        b=Rtbw4LRIJ1kE9bXahLxt6jjqgT7IuGRAGC5vKuCaNITZ8y/jjLv2+41WeAkla9dgSG
         viMJe/sOzRlWvdsEIzQ9UB0WMqpuDg9oobEcmAK08nYreEDhEKr+BuKCpwJlhTH9Daex
         LyOYo7H2fdQfrkLNs9lgK2T2FAack43mZTAysrg8nBrSvV9+EYMouVwsLbMVjL/FFV4n
         mWN0AchFAwwl9psKakmQ+AsmZCslUJmlB86Hbk+wxy4ICroMDpZS4eEMeReVGMzHH/qM
         +H7xcU8ioJodSl8/uMdIhQvYxerkcZ/bYCTsQYaawM19AM0JODVW+5tM58hAeqLsJR8J
         RFjg==
X-Gm-Message-State: APjAAAU+kYHRU2t63tBRdK4qhd09NVIs8WTyxKGRQ6muxnWVjRo5AWbZ
	DmDY26qsCPshp5s+rRGLY3MCWQ==
X-Google-Smtp-Source: APXvYqyNfp4Kjw+jg1hLvf40WU2jLru794eUymevTioldXyEv4NhlVAUwGjhOu7hdsG21dW0uSwopA==
X-Received: by 2002:a5d:9747:: with SMTP id c7mr15839819ioo.244.1566260223776;
        Mon, 19 Aug 2019 17:17:03 -0700 (PDT)
Received: from [192.168.1.112] (c-24-9-64-241.hsd1.co.comcast.net. [24.9.64.241])
        by smtp.gmail.com with ESMTPSA id k7sm12530367iop.88.2019.08.19.17.17.02
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Aug 2019 17:17:03 -0700 (PDT)
Subject: Re: [Linux-kernel-mentees] [PROJECT] clean up swapcache use of struct
 page
To: Matthew Wilcox <willy@infradead.org>,
 linux-kernel-mentees@lists.linuxfoundation.org, linux-mm@kvack.org,
 kernel-janitors@vger.kernel.org, Shuah Khan <skhan@linuxfoundation.org>
References: <20190819235456.GA9657@bombadil.infradead.org>
From: Shuah Khan <skhan@linuxfoundation.org>
Message-ID: <f69a2e2e-ec21-efd6-4787-59f1c77885b3@linuxfoundation.org>
Date: Mon, 19 Aug 2019 18:17:02 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190819235456.GA9657@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On 8/19/19 5:54 PM, Matthew Wilcox wrote:
> 
> This would be a good project for someone with a little experience and
> a lot of attention to detail.
> 
> The struct page is probably the most abused data structure in the kernel,
> and for good reason.  But some of the abuse is unnecessary ... a mere
> historical accident that would be better fixed.
> 
> Page cache pages use page->mapping and page->index to indicate which file
> the page belongs to and where in that file it is.  page->private may be
> used by the filesystem for its own purposes (eg buffer heads).
> 
> Anonymous pages use page->mapping to point to the anon VMA they belong
> to and page->index to record the offset within the VMA.  Then, if they
> are also part of the swap cache, they use page->private to record both
> the offset within the swap device and the index of the page within the
> swap device.
> 
> Then we get abominations like:
> 
> static inline pgoff_t page_index(struct page *page)
> {
>          if (unlikely(PageSwapCache(page)))
>                  return __page_file_index(page);
>          return page->index;
> }
> 
> My modest proposal for deleting the first two lines of that function is
> to first switch the uses of page->private and page->index for anonymous
> pages.  Then move the swp_type() back from page->index to page->private
> again [1].
> 
> I am willing to review patches and provide feedback.  I can go into more
> detail about how I think this should be tackled if there's interest.
> Also, if you know more than I do about the MM and think this is a bad
> idea, please do say ;-)
> 

I will be happy to add it to the project list for Spring session.

We can work together to come up with a task list to get the candidates
up to speed during the application process period which starts on Nov 1st.

> This is going to be a tough project because there are a lot of
> rarely-tested paths which directly reference (eg) page->index, and they
> might be talking about a page cache page or a swap page.  This is not
> a simple Coccinelle script.

Yes mm isn't an easy area especially for new developers. We can work
together to come up with a task list to get the candidates up to speed
during the application process period which starts on Nov 1st.

> 
> [1] We have enough bits to do this; on a 32-bit machine, we can at most
> have a VMA which covers 4GB memory and with a 4kB page size, that's only
> 20 bits needed to encode all possible offsets within a VMA).

That being said, I will wait for other mm experts weigh in.

thanks,
-- Shuah


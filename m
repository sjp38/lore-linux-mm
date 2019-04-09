Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B6E1C10F0E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C94A7206C0
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 13:31:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C94A7206C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59C326B000E; Tue,  9 Apr 2019 09:31:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5497D6B0010; Tue,  9 Apr 2019 09:31:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4603B6B0266; Tue,  9 Apr 2019 09:31:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C19C6B000E
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 09:31:28 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d8so14361735qkk.17
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 06:31:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=iQ/be5gcP57ja8QS2fif8abmySnQekyGUoKgB6lvQBw=;
        b=H83f1C4t6mSC+pZMRdPDZihv6P5lIzpV+3cjb4OKsZWfGnqhRLDkyXt7Eid6yM+kc3
         yo9OVEBJtvSB+zyzB0EJAkkCotRFC/b7j7EG2re5iRC/VSz4+xjwg4uTWcU7pgOejEj6
         pLHG5fwg21G8P5TiwAxCvDPHIyLPQ/5ErVwi9evbIk3f6hXf2O2A8MDzr3bczH62d+5L
         Sr+/NXkHhZWoyvupvw4LL6/BS67C7ppEdBztJ57UrOclir9WAGrzI7CW17nqlc5s8lyQ
         UTbmyiagyQ751EuLDjd7YNR6qfmzkbrHuyUVxXq6GeUd40927ILLsW6JY/SdTfX5qGke
         ZIjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX7rDtGAiQ+G2ZwKMwNp3fOWjR5oL4wDNgNTCg9c7BB3dBzTo3R
	hvHLez2K0wPVmEpzXZ4q0IP306mSvIWC7y1oCE/Sj0eQmElwtRHMN4o6uBcOD+dMRBKFyRbGewF
	3k3cmRLdYPnQOwEl4OW3BanEEIEPT83+UYXYtr6Dbj6JSQlTfuPUh4i2Yoe7BI9brSw==
X-Received: by 2002:ac8:19f0:: with SMTP id s45mr29642771qtk.86.1554816687947;
        Tue, 09 Apr 2019 06:31:27 -0700 (PDT)
X-Received: by 2002:ac8:19f0:: with SMTP id s45mr29642724qtk.86.1554816687389;
        Tue, 09 Apr 2019 06:31:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554816687; cv=none;
        d=google.com; s=arc-20160816;
        b=WjwtBMGgxQzEC42GHxuhOtACQfUNTOmlCzIuiR+KryYkDyjKaP+CI3gO4s/0+H2Epv
         O8SWONcLvWg00XX53sus6HjZLmuA4obLUgRa9q4AittIQqco5IwHOJpdgOR+D4jUp3VL
         4FEgx63T83cmPiziRS1IeuQ3gCTEFglUv6PjH54XOVMXBt8zPLWaJu/4wwHUEyWXnkiM
         BBK6SuNZbKZz7UEPNyzXOOdNIAILEBi/D6IOY14zkRbfqeFU6cMPFYV0Mf4DtDYB4xYy
         vXaV12cB0HlHiZMJnNoXzDeElN26Lc2USGoDFpBfdBSD7Mzwyr0my/XAoFSc6X1bVomD
         nwPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=iQ/be5gcP57ja8QS2fif8abmySnQekyGUoKgB6lvQBw=;
        b=rCF7+mk7YjIIZ9AiyB8qoHnLIw7zUFfT62TW5drvbaIuThl621rLB6ZCSAUF2UVVFX
         DNbMQcrh9xkXrSlX1VNb67nhIrOHbylU98FeREUxVhIkXy5tXiuBytIbxeoo3JMt6lAO
         0gFEYHvm5zAcjq2emrkkHBZuyk5B6akujUWNVJ0HEzcLZwZAhVcgzC0pgWRp8cZEyrBD
         E5nwit7iVaptD5kFUeqmYm8wQRmvTOUCPfSimOwKQLly5kF3qsV93x8sQ5hTNnFc4Kma
         uVppSwWbR7BoH31N29FH7thYW4J5a14H2rsIhf77nTHP13KSiEwWoAHDQrrw3+e+97+f
         gUww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k3sor19843872qkf.101.2019.04.09.06.31.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Apr 2019 06:31:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqxbrl9TI0FxmrWsS4ec//7ojsf+1C5OLlAEmLcfDwWlkw58TfVAGN4rnpu0WLtzYV73t8C/HA==
X-Received: by 2002:a05:620a:132b:: with SMTP id p11mr27788585qkj.279.1554816687062;
        Tue, 09 Apr 2019 06:31:27 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id m31sm23156297qtm.46.2019.04.09.06.31.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 09 Apr 2019 06:31:26 -0700 (PDT)
Date: Tue, 9 Apr 2019 09:31:18 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Nitesh Narayan Lal <nitesh@redhat.com>,
	kvm list <kvm@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Paolo Bonzini <pbonzini@redhat.com>,
	lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
	Yang Zhang <yang.zhang.wz@gmail.com>,
	Rik van Riel <riel@surriel.com>, dodgen@google.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, dhildenb@redhat.com,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Thoughts on simple scanner approach for free page hinting
Message-ID: <20190409092625-mutt-send-email-mst@kernel.org>
References: <CAKgT0Ue4LufT4q4dLwjqhGRpDbVnucNWhmhwWxbwtytgjxx+Kw@mail.gmail.com>
 <d2413648-8943-4414-708a-9442ab4b9e65@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d2413648-8943-4414-708a-9442ab4b9e65@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 09, 2019 at 11:20:36AM +0200, David Hildenbrand wrote:
> BTW I like the idea of allocating pages that have already been hinted as
> last "choice", allocating pages that have not been hinted yet first.

OK I guess but note this is just a small window during which
not all pages have been hinted.

So if we actually think this has value then we need
to design something that will desist and not drop pages
in steady state too.

-- 
MST


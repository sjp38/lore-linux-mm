Return-Path: <SRS0=8wNw=XE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,SUBJ_ALL_CAPS,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A573C4740C
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:00:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2907521479
	for <linux-mm@archiver.kernel.org>; Mon,  9 Sep 2019 17:00:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2907521479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9FDF06B0007; Mon,  9 Sep 2019 13:00:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9AE856B0008; Mon,  9 Sep 2019 13:00:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C5AC6B000A; Mon,  9 Sep 2019 13:00:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0228.hostedemail.com [216.40.44.228])
	by kanga.kvack.org (Postfix) with ESMTP id 6994E6B0007
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 13:00:13 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 1A80D181AC9AE
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:00:13 +0000 (UTC)
X-FDA: 75915995106.16.rake40_3c034dd6e1024
X-HE-Tag: rake40_3c034dd6e1024
X-Filterd-Recvd-Size: 4754
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf43.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:00:12 +0000 (UTC)
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1C26785543
	for <linux-mm@kvack.org>; Mon,  9 Sep 2019 17:00:11 +0000 (UTC)
Received: by mail-wr1-f69.google.com with SMTP id b15so7649331wrp.21
        for <linux-mm@kvack.org>; Mon, 09 Sep 2019 10:00:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:openpgp:message-id
         :date:user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=D0EEdCwjKZAloFiFZzRmxXTgf/1c/anbaaWwH/4atiA=;
        b=AiLNQgKKjhI0k3J8aa6XaBl339+MgNz7Q75X/j8mf/3tuEa4EB93/9rPRW+Y0klYwf
         ZfmXI0mfKzgI9D15kXOmTXY7MiBsOQD9Hf+vNG5tmIZt3dmm/S53lpZQuApvWenjNbk7
         koDMwePUG5xQGQQ1kLIMgMA5Ip4+ppF/xmiY7nRCHyxygFel9prXgb8QBOrjAhTwsHTF
         Fc9c+L9jmi15ffloAJQWPePnZVvhc+0fSXzI2OdIQmEYIcbuEjMHggTdIpqgG6DWw2On
         ClxOad4p98euBHkdTG1XARQ1+i7m/noPETw98Hnqiw+VjS81FIEXb58FibrcaL0nokCY
         J/Og==
X-Gm-Message-State: APjAAAVvOrd4qsOiN5zWY9O8id++5YMWmgp9n1YLiS54yt0K6XH246H6
	5u8nAKIaoG9nu5g+msEnSiWv+nkDnmENw2PvKQYsB+Gi20+qqyFhE+185oixf2teVoDxYQObJ+J
	wMsWV9UO3oIc=
X-Received: by 2002:a5d:66d2:: with SMTP id k18mr19678355wrw.7.1568048409643;
        Mon, 09 Sep 2019 10:00:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXJaVNu/2/fZCHTtIWw35qwKTZd4unUZx6BMsLts8oOV6M65uq4VD5n7+CBECGa01osKa5IQ==
X-Received: by 2002:a5d:66d2:: with SMTP id k18mr19678322wrw.7.1568048409413;
        Mon, 09 Sep 2019 10:00:09 -0700 (PDT)
Received: from ?IPv6:2001:b07:6468:f312:4580:a289:2f55:eec1? ([2001:b07:6468:f312:4580:a289:2f55:eec1])
        by smtp.gmail.com with ESMTPSA id d28sm16924627wrb.95.2019.09.09.10.00.08
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Mon, 09 Sep 2019 10:00:08 -0700 (PDT)
Subject: Re: DANGER WILL ROBINSON, DANGER
To: Jerome Glisse <jglisse@redhat.com>,
 Mircea CIRJALIU - MELIU <mcirjaliu@bitdefender.com>
Cc: =?UTF-8?Q?Adalbert_Laz=c4=83r?= <alazar@bitdefender.com>,
 Matthew Wilcox <willy@infradead.org>,
 "kvm@vger.kernel.org" <kvm@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "virtualization@lists.linux-foundation.org"
 <virtualization@lists.linux-foundation.org>,
 =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
 Tamas K Lengyel <tamas@tklengyel.com>,
 Mathieu Tarral <mathieu.tarral@protonmail.com>,
 =?UTF-8?Q?Samuel_Laur=c3=a9n?= <samuel.lauren@iki.fi>,
 Patrick Colp <patrick.colp@oracle.com>, Jan Kiszka <jan.kiszka@siemens.com>,
 Stefan Hajnoczi <stefanha@redhat.com>,
 Weijiang Yang <weijiang.yang@intel.com>, Yu C <yu.c.zhang@intel.com>,
 =?UTF-8?Q?Mihai_Don=c8=9bu?= <mdontu@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
 <20190809160047.8319-72-alazar@bitdefender.com>
 <20190809162444.GP5482@bombadil.infradead.org>
 <1565694095.D172a51.28640.@15f23d3a749365d981e968181cce585d2dcb3ffa>
 <20190815191929.GA9253@redhat.com> <20190815201630.GA25517@redhat.com>
 <VI1PR02MB398411CA9A56081FF4D1248EBBA40@VI1PR02MB3984.eurprd02.prod.outlook.com>
 <20190905180955.GA3251@redhat.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Openpgp: preference=signencrypt
Message-ID: <5b0966de-b690-fb7b-5a72-bc7906459168@redhat.com>
Date: Mon, 9 Sep 2019 19:00:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190905180955.GA3251@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/09/19 20:09, Jerome Glisse wrote:
> Not sure i understand, you are saying that the solution i outline above
> does not work ? If so then i think you are wrong, in the above solution
> the importing process mmap a device file and the resulting vma is then
> populated using insert_pfn() and constantly keep synchronize with the
> target process through mirroring which means that you never have to look
> at the struct page ... you can mirror any kind of memory from the remote
> process.

If insert_pfn in turn calls MMU notifiers for the target VMA (which
would be the KVM MMU notifier), then that would work.  Though I guess it
would be possible to call MMU notifier update callbacks around the call
to insert_pfn.

Paolo


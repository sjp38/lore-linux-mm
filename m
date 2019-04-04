Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4D11C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:10:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4399F2082E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:10:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4399F2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ADC206B0003; Thu,  4 Apr 2019 10:10:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A64846B0006; Thu,  4 Apr 2019 10:10:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E01B6B0007; Thu,  4 Apr 2019 10:10:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 390356B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 10:10:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f2so1495547edv.15
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 07:10:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=dnsO4qfUVHQydV7Z84e+M79arvAO68kfbNr9ra2Ku2A=;
        b=Ht21OnA9wXX1uiR+LhnbGNks+yzqzC36TFuMClb8u4yIzfKcFhCTwT1IU3h14LjbV9
         lfL5+sfhSwpNral0j/Op+PHo9u8fLaWNi5BjVyxmEi7vD6xmVNe3NsnloVKZFgPlwg6N
         9Wg+RZgjUyGBeem+8bd4debHuOgmLa9iWzUVK7uWH68EqIPeAvcIBrq7JVNtao1kO18Q
         Z2ju565QDhDTUaJMw0UKbb2d6QqbLuFkG2Y/hqxh/rMBbQhO7MqjLnj56noMFI+Hnj/A
         1mQfcAfTXm+8/CsTNZno/HOOU5hK+in+pA+wmEhvakssXUcokYrTcgwDqqRuOYWioQt2
         SAtQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAW4TlM+qaKTp0W/MBiO7MCfjtuXLVQ7llvncdreQe1ZmtPWRynQ
	vCKnUeRw4wXKMSl/gjzE3Vvhsi8GlzDY5iNByW4OyJdoavwE17MDY6C51nEnzql2TdtTYtJagPF
	Puug+kXPK9A2fm+0E18tWXBEFgu0E62I5IFuu3hQ/lciNpLgwjXl2qYVO/lEYcaNyPw==
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr3874102ejb.106.1554387038763;
        Thu, 04 Apr 2019 07:10:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqymX/J6PlcS+uRMYQRnWsH8TUKHW7Zmvtl0NSPEI1YsqoWWifj0k/wfxeI0uT1lSkqtfhrZ
X-Received: by 2002:a17:906:b34c:: with SMTP id cd12mr3874031ejb.106.1554387037623;
        Thu, 04 Apr 2019 07:10:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554387037; cv=none;
        d=google.com; s=arc-20160816;
        b=KbeOBAPD+RAJaRhhbBW8ddTnuKVd2eots8eOqeVq7S4kzILALGlSdRuCdZKG6UvVF6
         AQD6wO6QwC2W9utstKsAjTK1wJXbTbtsy8AfXgbtBmyri99SGn1aX9r9nWDOIZ2Ve+G2
         m2EplYzdOduC9k4CywmYRa90oz7qiFBdTIJEp+paabWoimsUguadq6K+l2tIFMLAOKlU
         QjQwWQ70U94Rk2PR2ZQiYSgg4gEJMZf9OEeZcIp7BtjD++jBpe+7Waltg4HmLVE4ubBN
         qeau7tDLeV5dBmQnQcgKNeli4wrjutsDTitfMONlwDUwJRZMYrDyr1NzvPcskcTMLpCQ
         PI8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=dnsO4qfUVHQydV7Z84e+M79arvAO68kfbNr9ra2Ku2A=;
        b=dnPnkkWavl+AXGTSuXbGN5pw10ueQygzajTbVhc5BgPRiL7myLlW4/gkeEroeI8qls
         Y81OXUbXKXgzR+cJ586Rk6ZDW7p0jr6hsBrrcBpjk9/Jn0suEJivRAfWe/Zh8KoyU0mb
         ELfKh1+Dm17vswyMgwcvbct7wbGwpBq/lSGQnFTrF7zEuWafDe04vgKT3C407RmIKsRY
         KmVNm3dDplqg7fNoMW6oG8pUYWcFftWQK4eut+ohlBmuGbyfCUS6v6t/jSGzZiLeyZu6
         rMitUhb1rMUlwfkLEFmjo9zeGyKDpRZeiPz0PU84BfEEE2GmqXTY+1bezeFvB5+Ysrqz
         PsmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f2si4338062edb.413.2019.04.04.07.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 07:10:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 83641B14C;
	Thu,  4 Apr 2019 14:10:36 +0000 (UTC)
Subject: Re: [Bug 203107] New: Bad page map in process during boot
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Jan Kara <jack@suse.cz>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-ext4@vger.kernel.org,
 linux-mm@kvack.org
References: <bug-203107-13602@https.bugzilla.kernel.org/>
 <20190402101613.GF12133@quack2.suse.cz>
 <20190404130839.5tkpwihuct4mex32@kshutemo-mobl1>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <7ff105df-f572-54e2-345e-047ed317fa65@suse.cz>
Date: Thu, 4 Apr 2019 16:10:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.0
MIME-Version: 1.0
In-Reply-To: <20190404130839.5tkpwihuct4mex32@kshutemo-mobl1>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/4/19 3:08 PM, Kirill A. Shutemov wrote:
> On Tue, Apr 02, 2019 at 12:16:13PM +0200, Jan Kara wrote:
>> Switching to email...
>>
>> On Fri 29-03-19 20:46:22, bugzilla-daemon@bugzilla.kernel.org wrote:
>>> https://bugzilla.kernel.org/show_bug.cgi?id=203107
>>>
>>>             Bug ID: 203107
>>>            Summary: Bad page map in process during boot
>>>            Product: File System
>>>            Version: 2.5
>>>     Kernel Version: 5.0.5
>>>           Hardware: All
>>>                 OS: Linux
>>>               Tree: Mainline
>>>             Status: NEW
>>>           Severity: normal
>>>           Priority: P1
>>>          Component: ext4
>>>           Assignee: fs_ext4@kernel-bugs.osdl.org
>>>           Reporter: echto1@gmail.com
>>>         Regression: No
>>>
>>> Error occurs randomly at boot after upgrading kernel from 5.0.0 to 5.0.4.
>>>
>>> https://justpaste.it/387uf
>>
>> I don't think this is an ext4 error. Sure this is an error in file mapping
>> of libblkid.so.1.1.0 (which is handled by ext4) but the filesystem has very
>> little to say wrt how or which PTEs are installed. And the problem is that
>> invalid PTE (dead000000000100) is present in page tables. So this looks
>> more like a problem in MM itself. Adding MM guys to CC.
> 
> 0xdead000000000100 and 0xdead000000000200 are LIST_POISON1 and
> LIST_POISON2 repectively. Have no idea how would they end up in page table.

It's possible that CONFIG_DEBUG_LIST could catch the issue. Between
5.0.0 to 5.0.4 it should be also relatively easy to bisect with the
stable git tree [1], although if it happens randomly, you need to
perform enough attempts to accurately determine which commit is "good".

[1] git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git


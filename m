Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D7F7C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:27:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 118FF20815
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 09:27:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 118FF20815
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99C088E0002; Fri,  1 Feb 2019 04:27:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 923648E0001; Fri,  1 Feb 2019 04:27:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED528E0002; Fri,  1 Feb 2019 04:27:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19CFC8E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 04:27:41 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so2602666eda.3
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 01:27:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=xDmYT67T3PYWvz1SSfWfoPBuLct1ML30w0rMP5Ldyig=;
        b=Ihs1DnbmYLYcC1E1h3ifLr/ThfXjoO8Mw4qh4c5fInZfkVmrijZvRKDgfGe26RnBhL
         ikmFHtHophlU7U4I0WOSrZ/HOY6LqgDSddCCwXLj4JAYcFcAGZdHtL5l7Zl51zIPP6VO
         6C/9QUkuj5od8ORnCZEPxxFL5+Zp35qE0p6W7uPMkPdqorI/Gl14wntogOJC1bd+qSLA
         RFuy89ebjqkzIUtOQ2yboIMsLWjvm4kJ97dhKqd7WMTNGxyltQJyhOFdkU81FoB+jK95
         S9krHKIC86zFJhNUuh7+pVj79RYYF6m56PUSrsUagcWRbob6IvRUM38n/zvW1L20xSqh
         C1bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: AJcUukfU0ZXzlty6uFceQmV7SOa/qJBxRDUSgUPhEG9XOIncnZBVy2Aw
	Jpj+mWGSMETJq11A9++oggiBAbJs8KgMRVN4dX5gKvDe7qjReCqk1GkR1kuQ1/41z4VW1TrtABP
	+nAnmwbd5Vm5PJSEZGuzRusO64aR37bRFRUdMa2VgkZY7aLcBIwfQHyAtu/3HqIuLpg==
X-Received: by 2002:a50:ae64:: with SMTP id c91mr37619562edd.222.1549013260610;
        Fri, 01 Feb 2019 01:27:40 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5mxGfyCq6k/460jqYXLBBo2RftaL9UFDbDSnQ1+QxGV/hbPjGU/76LdJhRXP8HeorGZplY
X-Received: by 2002:a50:ae64:: with SMTP id c91mr37619512edd.222.1549013259748;
        Fri, 01 Feb 2019 01:27:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549013259; cv=none;
        d=google.com; s=arc-20160816;
        b=rRVxTN7VSuahATnDYW2ILExgg33GM3jh+atfiRYTJn+wOR3w3QU4BlT/aGB2skE43n
         tU2si2pwr/jxQhkn0bxqfnSZIas/v6/KwH99ACLbHDzYhO0NBJclB1f1CiCWkjxfBK8O
         9UMNWenQy6hGrey8ctVhTxPuI4sprKj2MVrfEh5D3ODErocs35kw13VACis9unF6eMxh
         INwDpHzYgqxkOip7dV4X3o2L+ycvkKcvdo1nGAc+Vgb59d6Mh58S1B6NHKhIdLySL8WD
         y+gCOgyom4zz7k6+yiELF7ybyllcAxjL9ZdfrZMD5UlZTnD9/g04fsrsXLo3YnzC6ClD
         9VlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:openpgp:from:references:cc:to:subject;
        bh=xDmYT67T3PYWvz1SSfWfoPBuLct1ML30w0rMP5Ldyig=;
        b=fUUChYx3dSMFngRiWdaDDt3zADVXbPEH0yu1x1Fbv3nuRBhVj6uCL0SQ1AasnNYTn7
         JHrhPjHyKaS9gd9liO3Rb4zd2KrzOA/IQuFK4Gzq8ebGfxlEBiM+w4R2S3VzLR0+xZEj
         YmzCuXGL7AvJ6EczO87EDR9uSySy8a19784G2JlwfnvigoLhSCxaTghCit0wiZHWQy9J
         yQl4fL1X+EQ3LMCxC3hRoi4RDXtxNGtnUCnF5EiuGg+s3o9S4r89pbidOu3JUmrOwCLB
         lt5GwyNgEntA6rSdXFtERfic/F921yXYfuDTzsgNeU3pMFPrr1hisxt3AivnIMjSlbwv
         yAnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b26si1031709edt.410.2019.02.01.01.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 01:27:39 -0800 (PST)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 26690AB7D;
	Fri,  1 Feb 2019 09:27:39 +0000 (UTC)
Subject: Re: [PATCH 3/3] mm/mincore: provide mapped status when cached status
 is not allowed
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org,
 Peter Zijlstra <peterz@infradead.org>, Greg KH <gregkh@linuxfoundation.org>,
 Jann Horn <jannh@google.com>, Jiri Kosina <jikos@kernel.org>,
 Dominique Martinet <asmadeus@codewreck.org>,
 Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>,
 Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>,
 Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
 "Kirill A . Shutemov" <kirill@shutemov.name>, Daniel Gruss
 <daniel@gruss.cc>, Jiri Kosina <jkosina@suse.cz>,
 Josh Snyder <joshs@netflix.com>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-4-vbabka@suse.cz>
 <20190131100907.GS18811@dhcp22.suse.cz>
 <99ee4d3e-aeb2-0104-22be-b028938e7f88@suse.cz>
 <20190201091152.GG11599@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Message-ID: <e1478ab8-e009-9bdd-3866-f319bd7259a0@suse.cz>
Date: Fri, 1 Feb 2019 10:27:38 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190201091152.GG11599@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/1/19 10:11 AM, Michal Hocko wrote:
> On Fri 01-02-19 10:04:23, Vlastimil Babka wrote:
>> The side channel exists anyway as long as process can e.g. check if
>> its rss shrinked, and I doubt we are going to remove that possibility.
> 
> Well, but rss update will not tell you that the page has been faulted in
> which is the most interesting part.

Sure, but the patch doesn't add back that capability neither. It allows
to recognize page being reclaimed, and I argue you can infer that from
rss change as well. That change is mentioned in the last paragraph in
changelog, and I thought "add a hard to evaluate side channel" in your
reply referred to that. It doesn't add back the "original" side channel
to detect somebody else accessed a page.

> You shouldn't be able to sniff on
> /proc/$vicimt/smaps as an attacker.




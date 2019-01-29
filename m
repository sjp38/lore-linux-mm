Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 875AEC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:48:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DA3120844
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:48:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DA3120844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D98318E0003; Tue, 29 Jan 2019 13:48:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D530A8E0004; Tue, 29 Jan 2019 13:48:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C103A8E0003; Tue, 29 Jan 2019 13:48:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 68CFB8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:48:55 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so8208338edd.11
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:48:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WOkPaBRU+Px9/6r9HBMrjnl+0hgU04iAIF61TeS6oGw=;
        b=eOO+4kNMT0cj/ZdrNfragxFrz2JFhLPmnGC9TwnX6/+iHVxnkHRdw2glc8+jsx9DA+
         MMYnc70JIa7NLlxXtDl+ABqX8bUbSQ6+ypWZP4D/vOQ2jtgLjueNZcOeUw3qU3myXfNT
         LtJKMbaEeqNUoWA3UpTlRSApYJICtsMfgKYmrrtY1bfAjgvUGutFG54sbT+lhJVLDd6l
         6hls83oY5tYdQ2b3e1W1SvvDB7+x2mQNKZ7Dz7FXq6iEJctaROqhiWI/v8ebfjMXE543
         RY5zw+GdbtEm9MIH3FdY27HYp7Jpw34ONEOGcntib9Os42PHmaCa2JbzWrRjWvQ5rmcd
         5J7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AJcUukdd7/rlG+T2ZHjuquROLAXx0flb6KHyWVWTeq8RmxXh4/JFVlMk
	WEKzIDGrpMU6UUU4vR0w0Tg+y7nZZKJ+AGnl5cRu8ybmuSfEXbhhLd21KGR6r9aVuC76dT/4WFs
	e7eM10LTpdEolHqOTxJnHO1tGkGyRLN2cEJQUkv3kkDRg1hD5aqojzzzEYcbSf6KlUg==
X-Received: by 2002:a50:b68a:: with SMTP id d10mr26839913ede.16.1548787734957;
        Tue, 29 Jan 2019 10:48:54 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4GUwCdveoq9u/w+kTziqCV8Fewmw6VghkuueDy0j7VUyTmouY4OTJVjGaki+QOE+DmS2BM
X-Received: by 2002:a50:b68a:: with SMTP id d10mr26839867ede.16.1548787734142;
        Tue, 29 Jan 2019 10:48:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548787734; cv=none;
        d=google.com; s=arc-20160816;
        b=wYWP5PFjLnYJCoulznEjg+3M+CYODzE4lPdw9sEXc+ucXc72FpV/koD3cOimskNye6
         9iqOkJKeHAE4t2/CIGc2Pv6WM9KpX2m4uCegtCljWKtXCDZ9Og+RGhVVhJB0puU6pa58
         UMx2GI/5sB2c+g2T4ysIHF6vk5qnJQm9CFHilH0jn9IiHSWdhUwKq5zwX+4oK64knMMk
         rg9K21tkBNHMlr3szbQBzdGZbAvS0womS2OQSZ2T3G9HVse4P7+w4xNxyL0h85Y+XoS6
         2PJt/JjqHpK5RkVxFcbx0SlO0X/tvlTsmeU2+dvtVrN60Csw8qzp9b56+smOkH46+syw
         fe0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WOkPaBRU+Px9/6r9HBMrjnl+0hgU04iAIF61TeS6oGw=;
        b=h5jVrUb8j8Wx42ab+CIHLlYDQBU8nLh1GheVDQvCnlcngfCJJ+QBAnmU9Z6GjkNP1A
         c/nUxGCeVl1W7KmF8CiVZdrm7HC8KYwnck9Z5AsL0U5GfOqbeO3UmkltwcDMCGYOb0Ab
         b7g5Gs/5lrNC4UqbKkAxxXzMBUNDsI7Qu8TD2NNS6QM33geX/7geCqSa3k4t/D9OGf7Y
         pXCjX1TTv85KH8J3CcN/BlkkFh0DpJolw5ZqCDK29HhAzI0fn4W7AGTRLWZ/tfE2+b3X
         ATECFxWa9f38EknA/9/P8YT5lCHjFsd2GVJi9wI2YNY9RAWdCiIdCfsM7XxSbOeGZhRO
         nc/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g5si196089ejt.243.2019.01.29.10.48.53
        for <linux-mm@kvack.org>;
        Tue, 29 Jan 2019 10:48:54 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C97D9A78;
	Tue, 29 Jan 2019 10:48:52 -0800 (PST)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 120C33F557;
	Tue, 29 Jan 2019 10:48:49 -0800 (PST)
Subject: Re: [PATCH v7 10/25] ACPI / APEI: Tell firmware the estatus queue
 consumed the records
To: Tyler Baicar <baicar.tyler@gmail.com>
Cc: Borislav Petkov <bp@alien8.de>, Linux ACPI <linux-acpi@vger.kernel.org>,
 kvmarm@lists.cs.columbia.edu,
 arm-mail-list <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org,
 Marc Zyngier <marc.zyngier@arm.com>,
 Christoffer Dall <christoffer.dall@arm.com>,
 Will Deacon <will.deacon@arm.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Rafael Wysocki <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
 Tony Luck <tony.luck@intel.com>, Dongjiu Geng <gengdongjiu@huawei.com>,
 Xie XiuQi <xiexiuqi@huawei.com>, Fan Wu <wufan@codeaurora.org>
References: <20181203180613.228133-1-james.morse@arm.com>
 <20181203180613.228133-11-james.morse@arm.com>
 <20181211183634.GO27375@zn.tnic>
 <56cfa16b-ece4-76e0-3799-58201f8a4ff1@arm.com>
 <CABo9ajArdbYMOBGPRa185yo9MnKRb0pgS-pHqUNdNS9m+kKO-Q@mail.gmail.com>
 <20190111120322.GD4729@zn.tnic>
 <CABo9ajAk5XNBmNHRRfUb-dQzW7-UOs5826jPkrVz-8zrtMUYkg@mail.gmail.com>
 <0939c14d-de58-f21d-57a6-89bdce3bcb44@arm.com>
 <CABo9ajB9TAkycLbe++yyDibXx33MntNV_Hy27JSXCVsvP6rf7g@mail.gmail.com>
From: James Morse <james.morse@arm.com>
Message-ID: <1530de77-3f9d-f214-216e-42eec7d757b7@arm.com>
Date: Tue, 29 Jan 2019 18:48:40 +0000
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CABo9ajB9TAkycLbe++yyDibXx33MntNV_Hy27JSXCVsvP6rf7g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Tyler,

On 11/01/2019 20:53, Tyler Baicar wrote:
> On Fri, Jan 11, 2019 at 1:09 PM James Morse <james.morse@arm.com> wrote:
>> We can return on ENOENT out earlier, as nothing needs doing in that case. Its
>> what the GHES_TO_CLEAR spaghetti is for, we can probably move the ack thing into
>> ghes_clear_estatus(), that way that thing means 'I'm done with this memory'.
>>
>> Something like:
>> -------------------------
>> rc = ghes_read_estatus();
>> if (rc == -ENOENT)
>>         return 0;
> 
> We still should be returning at least the -ENOENT from ghes_read_estatus().
> That is being used by the SEA handling to determine if an SEA was properly
> reported/handled by the host kernel in the KVM SEA case.

Sorry, my terrible example code. You'll be glad to know I would have caught this
when testing it!


Thanks,

James


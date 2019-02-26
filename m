Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF43EC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:57:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A9C821852
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 11:57:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A9C821852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=axis.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 163CC8E0003; Tue, 26 Feb 2019 06:57:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C5DF8E0001; Tue, 26 Feb 2019 06:57:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E82718E0003; Tue, 26 Feb 2019 06:57:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 73D998E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:57:44 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id u13so2209119ljj.13
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 03:57:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DzA8XlhpCqjkpGRFyb9davwCKEonlhrFSYuD0gjjfiE=;
        b=S0P3lixEW/2hraufa78G9SoUkpH8aTc2SlBPt0kvtcBDpY0Oi9W2WdNU3SYYnUuSMO
         nHcA4Yi7c9ffx/kv4UKPMHhLISc4HtBs616k0yWO0PLj6Ed8NmwrujW+tixJt0pvg2v3
         FyblE+OZiNzKcB/4yWQBmbAB/0klCuoPxPEHm5zKH4s22NCxS9yMQr8n5r5L43QkF0GV
         JOx1iIdjYGwq7ZpmHN8XokfxYkd/dOxluM0cLb4blC7V//K29rJ3bZ8U5EDDsLByVLVN
         KTh8MfYoAPFaVrbV455obzl3EMOYBP+WtfGXvl0mWW4PnP8lun/WDTAfvtVaOwo/iI81
         0dKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
X-Gm-Message-State: AHQUAuasfiuopo24z3c/3tccyxfntnLdux5biHBKryFmuCdbg1pxKRdv
	J9e4hgC4u3MBlcVbcfRDg7RT9vDLqnoEFIMkX0ecPUPPd+jvMTehgm3q8lJGOHzi5Y34jBf9UiZ
	jPUfciSmDHuYOaIStH2CjkrRsb+vCBKRDVmiwd4Nb9/+Hk7L0T/cqMsg7ZecgKjvytg==
X-Received: by 2002:ac2:5227:: with SMTP id i7mr1217770lfl.24.1551182263852;
        Tue, 26 Feb 2019 03:57:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZEx8x+e0nPxPoVKmrzdzpqzYpURzn70PENZSy+ZZUy1qtJvnZinEX4LS2VVYjj3X3IGxRQ
X-Received: by 2002:ac2:5227:: with SMTP id i7mr1217727lfl.24.1551182262755;
        Tue, 26 Feb 2019 03:57:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551182262; cv=none;
        d=google.com; s=arc-20160816;
        b=wu2TN0GVBAG4GWHO5mDHXa1AJ19XwByRJ2KoTv6rRuH/nGbK1PgSfVSkNitrSTl2gw
         am7wGBQh9hl1uARkJXRxi9+5SvN+bLVO5bIcaUPX9pDwLGN4YG3BZewCTC5Ry+ITAifv
         fHe/weXLML9xfpH00FuBdyiGutcfW0ymPhuRCu7wOibb2srPha5b0g+chLuzJN+aYChz
         KeI2LzpBl52AYd/E5k/aUeXyqixTcyEN26vA8/pq4vqDr/5o9sq42zEsdZPTZ24S9d/+
         IhWWLTv2iZewmdcu4pRxqgxu64bVpgUTTSML/V1z8vgh0qElKhFTH51xuHJRarB5wvuE
         ewPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DzA8XlhpCqjkpGRFyb9davwCKEonlhrFSYuD0gjjfiE=;
        b=gO7T/AwlM1c/RXnyo63D3vvQ/mrc3RE9gtKAxC+gwjlpInIuvVdyv+M7Vjxkfhyl87
         Big3jGJORIgBQOMSu7Cb7Hfj3xdfmZxpqnzHyCM5zHw+K9YS34aR1Uo4SFT3HhTj/7BB
         U7HWfI+J3axEaAEAw9doFAx+nc702LMm2RODqQAXPGMMIjn1XqBP7ZYYiV7/a5qC6Z43
         Vps80Yq/ygzlNm1PxOxW0RgMdwPLM7h9PNaV3n+P+d4bk44GLfEBvsu4dsSmGJ3rKu36
         6EadYHpi4P9UpxPrknsg3lZYS/w8oduEUevLxhkQBv1ZZMOCzD1WgNi43Z+cAjXIKWUX
         zoBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from bastet.se.axis.com (bastet.se.axis.com. [195.60.68.11])
        by mx.google.com with ESMTPS id a7si8685942lfh.121.2019.02.26.03.57.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 03:57:42 -0800 (PST)
Received-SPF: pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) client-ip=195.60.68.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of lars.persson@axis.com designates 195.60.68.11 as permitted sender) smtp.mailfrom=lars.persson@axis.com
Received: from localhost (localhost [127.0.0.1])
	by bastet.se.axis.com (Postfix) with ESMTP id 423691846D;
	Tue, 26 Feb 2019 12:57:42 +0100 (CET)
X-Axis-User: NO
X-Axis-NonUser: YES
X-Virus-Scanned: Debian amavisd-new at bastet.se.axis.com
Received: from bastet.se.axis.com ([IPv6:::ffff:127.0.0.1])
	by localhost (bastet.se.axis.com [::ffff:127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id U9yypqn2ZoG4; Tue, 26 Feb 2019 12:57:41 +0100 (CET)
Received: from boulder03.se.axis.com (boulder03.se.axis.com [10.0.8.17])
	by bastet.se.axis.com (Postfix) with ESMTPS id B3628180B3;
	Tue, 26 Feb 2019 12:57:41 +0100 (CET)
Received: from boulder03.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 85E5D1E07B;
	Tue, 26 Feb 2019 12:57:41 +0100 (CET)
Received: from boulder03.se.axis.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 79B971E079;
	Tue, 26 Feb 2019 12:57:41 +0100 (CET)
Received: from thoth.se.axis.com (unknown [10.0.2.173])
	by boulder03.se.axis.com (Postfix) with ESMTP;
	Tue, 26 Feb 2019 12:57:41 +0100 (CET)
Received: from XBOX04.axis.com (xbox04.axis.com [10.0.5.18])
	by thoth.se.axis.com (Postfix) with ESMTP id 6D96076A;
	Tue, 26 Feb 2019 12:57:41 +0100 (CET)
Received: from [10.88.41.2] (10.0.5.60) by XBOX04.axis.com (10.0.5.18) with
 Microsoft SMTP Server (TLS) id 15.0.1365.1; Tue, 26 Feb 2019 12:57:41 +0100
Subject: Re: [PATCH] mm: migrate: add missing flush_dcache_page for non-mapped
 page migrate
To: Vlastimil Babka <vbabka@suse.cz>, Lars Persson <larper@axis.com>,
	<linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>
CC: <linux-mips@vger.kernel.org>
References: <20190219123212.29838-1-larper@axis.com>
 <65ed6463-b61f-81ff-4fcc-27f4071a28da@suse.cz>
 <ed4dd065-5e1b-dc20-2778-6d0a727914a8@axis.com>
 <2de280a9-e82a-876c-e13b-a2e48d89700a@suse.cz>
From: Lars Persson <lars.persson@axis.com>
Message-ID: <24af691e-03ab-d79a-ddbd-7057dcf46826@axis.com>
Date: Tue, 26 Feb 2019 12:57:37 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <2de280a9-e82a-876c-e13b-a2e48d89700a@suse.cz>
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: XBOX04.axis.com (10.0.5.18) To XBOX04.axis.com (10.0.5.18)
X-TM-AS-GCONF: 00
X-Bogosity: Ham, tests=bogofilter, spamicity=0.171532, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2/26/19 11:07 AM, Vlastimil Babka wrote:
> On 2/26/19 9:40 AM, Lars Persson wrote:
>>> What about CC stable and a Fixes tag, would it be applicable here?
>>>
>>
>> Yes this is candidate for stable so let's add:
>> Cc: <stable@vger.kernel.org>
>>
>> I do not find a good candidate for a Fixes tag.
> 
> How bout a version range where the bug needs to be fixed then?
> 

The distinction between mapped and non-mapped old page was introduced in 2ebba6b7e1d9 ("mm: unmapped page migration avoid unmap+remap overhead") so at least it applies to stable 4.4+.

Before that patch there was always a call to remove_migration_ptes() but I cannot conclude if those earlier versions actually will reach the flush_dcache_page call if the old page was unmapped.


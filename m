Return-Path: <SRS0=58dN=SL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 034F6C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:59:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEC4521874
	for <linux-mm@archiver.kernel.org>; Tue,  9 Apr 2019 12:59:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEC4521874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53DBD6B0008; Tue,  9 Apr 2019 08:59:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C5866B000D; Tue,  9 Apr 2019 08:59:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38CF66B000E; Tue,  9 Apr 2019 08:59:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id DD8796B0008
	for <linux-mm@kvack.org>; Tue,  9 Apr 2019 08:59:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k8so8608653edl.22
        for <linux-mm@kvack.org>; Tue, 09 Apr 2019 05:59:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uIvO0Bh+ze5opiMLu1WYLITUUhyx38LPIW5JC/Xq+uI=;
        b=qTKZecAOkzGYElQr61aDaYZtzt71yGUcI9aNIuh5orbTGLdHVd0dZo1XTUpQ2e1U+F
         JXQFPDfrMLabMOzRSzCM8Jk2/TPZKXObReioMiRWfXJcJrOdmv21RjlRTR9M9WxOSM46
         Ru+DqZs50MqrPfGU7yV/QJOv1n/plvExqSTUB6MwHeL1Quj9uOFe+/1zXB/VikM+h4yX
         D/zUHSTSARSDdB1EXlzBHv/LYSvPHCn5mwYs39qThA11P3iC6vhmpdVYO0ufS+63+jp2
         nB7cJBz5iL4+HrLbb39EPTiIg2yPJdkJBkTlj4+VbGpIJJEPaieKsVay8GzTVM9Xjkrq
         ZWbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAUduS9ewLyMNzJ0cbivC+swA3FybW/YtIKwSE3F3UmG7ri3jb7U
	WujDiuTaq1lNBvjcs9Rv66jsLuJWA0x+3ESsg057LUE2Dmf0Cql8V3tB3lIcamtds6EIuSSiDq7
	UwfzItwEpGQKcq7pqovMOiVjTL0GQVwcYZKNFCN3MQF1rtOfb2OBIhQtfL4xPOqTSCw==
X-Received: by 2002:a50:a705:: with SMTP id h5mr23236765edc.226.1554814796462;
        Tue, 09 Apr 2019 05:59:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWJQl+32EyqzRE1z9K9jULe9OdCmwtDw1fjTrIKA/rtqGPIpC5c9Ir7i5ptPVLHipvwIXl
X-Received: by 2002:a50:a705:: with SMTP id h5mr23236713edc.226.1554814795451;
        Tue, 09 Apr 2019 05:59:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554814795; cv=none;
        d=google.com; s=arc-20160816;
        b=eMOMUZURfCsMXuUn2ig/ApWCPgsJnYLqX75zvZ7U1CQ5jiVTrTZk67djTkIwvYu7tl
         wuYVqtJdKetAS4fFk4tidAFx396w2sB/c/EgaMLMg3VXwa7Lz+SuPCWECcNjiAXtUCC8
         PWM054GOo26chgJaf0jg/Sz8ANzUBoz9vul1//912CcBVMumcI5WLPlDSgRoBBxtTVJY
         Pu6pCysHfWDZVz6QJ/5iQ0NStQN/KQfaRrDEuM1ChotVMZXRSZd7H+CrBmjxSOLs7n8c
         5Zi6Lg3045tbJvlPmU03dVCFebS6ZA/BqXrwupaIJOAy4or2TLKcP13Mu6M859TflEbc
         GtvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=uIvO0Bh+ze5opiMLu1WYLITUUhyx38LPIW5JC/Xq+uI=;
        b=Ml8chs/U9EJto60izIKGoPRm4L06Rz9+0GXHxezpCLUxVWbztbe9+G3XWwo/VEaiQL
         qQkJb0bweKxWdK0q2KBBIghbe519gipwjcObdQL7SNgk3zJdAy1BQe21t0zZATlXVvIf
         okyUiZqODbvvYgVZxaJIEQcuffyTmph3BzpmaBADOslTlr0TVRg6VSj5bpaeUZolfVPE
         RgnvzENwOzmzgLp/VFKvlAIf2AaZcu8qGaHqRsLgockmrBZE67Wq5EitA0n2eTViTkqN
         zbc7bGLX6N0nfF9VEdNuMc85Zk0YsoGtq5mz00gNeByWutlWLykt5r+SOQb6+08SGaJL
         JtBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si3535394edx.387.2019.04.09.05.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Apr 2019 05:59:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 49F92AC31;
	Tue,  9 Apr 2019 12:59:54 +0000 (UTC)
Subject: Re: [PATCH v5 2/7] slob: Respect list_head abstraction layer
To: "Tobin C. Harding" <me@tobin.cc>, Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Matthew Wilcox <willy@infradead.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
References: <20190402230545.2929-1-tobin@kernel.org>
 <20190402230545.2929-3-tobin@kernel.org>
 <20190403180026.GC6778@tower.DHCP.thefacebook.com>
 <20190403211354.GC23288@eros.localdomain>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <63e395fc-41c5-00bf-0767-a313554f7b23@suse.cz>
Date: Tue, 9 Apr 2019 14:59:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190403211354.GC23288@eros.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/3/19 11:13 PM, Tobin C. Harding wrote:

> According to 0day test robot this is triggering an error from
> CHECK_DATA_CORRUPTION when the kernel is built with CONFIG_DEBUG_LIST.

FWIW, that report [1] was for commit 15c8410c67adef from next-20190401. I've
checked and it's still the v4 version, although the report came after you
submitted v5 (it wasn't testing the patches from mailing list, but mmotm). I
don't see any report for the v5 version so I'd expect it to be indeed fixed by
the new approach that adds boolean return parameter to slob_page_alloc().

Vlastimil

[1] https://lore.kernel.org/linux-mm/5ca413c6.9TM84kwWw8lLhnmK%25lkp@intel.com/T/#u

> I think this is because list_rotate_to_front() puts the list into an
> invalid state before it calls __list_add().  The thing that has me
> stumped is why this was not happening before this patch series was
> applied?  ATM I'm not able to get my test module to trigger this but I'm
> going to try a bit harder today.  If I'm right one solution is to modify
> list_rotate_to_front() to _not_ call __list_add() but do it manually,
> this solution doesn't sit well with me though.
> 
> So, summing up, I think the patch is correct in that it does the correct
> thing but I think the debugging code doesn't like it because we are
> violating typical usage - so the patch is wrong :)
> 
> thanks,
> Tobin.
> 


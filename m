Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D774C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 09:07:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A93121951
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 09:07:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A93121951
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B5656B0006; Wed, 24 Jul 2019 05:07:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 867196B0007; Wed, 24 Jul 2019 05:07:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 754818E0002; Wed, 24 Jul 2019 05:07:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B8816B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 05:07:39 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d11so38782938qkb.20
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:07:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=J0UoNtyjlXHyau5OZuzM07Yy9QCjbo2q8iYtmMl1W4U=;
        b=AgkeJujbnnJRzhCRg1acC1Lug35lYEibY/PByHsisu9daOfct/F0Z/q5H6y1ZZiVK5
         EMrjDW4YaPLJK3Z5VfEIPxgUO35nLbmx5C4YqJkmX5W5M6Qv7Nu9vtfghn93jJ4/E168
         X18sk4jtI1Uq19uS0sS5IyR9pyEzZgFKXXE02zm2+//bOEWDfaIaiiWbNxsbCZVncs3o
         TfP3iWFWv+H4CtfdCMGwxigi75CJOtGwcS1SvUvBANjk1R+xloAowAtVOyHjZ/DJjMZT
         DuJyZZWUUOMVU8pUK2P7AV5putlPySPur0oBduU1b3eVWh/R/16zQXf3i/9z2nsKilEy
         0buQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX/74GckbtSUvmcDklLmF8ukH2ZMHbB0Yasn0pM/hPgkhnSM7xm
	GIEliJ8mN6qVXLKR+xFMD3vdI51RpNalpyC5zLA0PG65phhtH/g3BAbKpqAmtEnntHmM2qpvXDG
	kuKaAHlRLU0DkVgROsCKosbI4noa8QtO/K2Mv8RW2kqu5bzA4lpwwpvKv+v+SID+Cjg==
X-Received: by 2002:a37:dcc7:: with SMTP id v190mr5313753qki.169.1563959259169;
        Wed, 24 Jul 2019 02:07:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwyLfycKHbIVar1cTiIID9RHorziDzrRUW1pX/jnQ4r90v3/C/Ci7RopPXxU2y+J0ksyQ8K
X-Received: by 2002:a37:dcc7:: with SMTP id v190mr5313730qki.169.1563959258779;
        Wed, 24 Jul 2019 02:07:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563959258; cv=none;
        d=google.com; s=arc-20160816;
        b=o5dUrDFzTcYWlNqgIaN8Kb5Z7ECIgespwGayFBimEz7Ij4ExqmthHTj1SXWiGC3X1T
         AXoPuxf3IndEtwOtHuqa6ogttNCUUGBZTe62R8BtvVFmzMtWCIabTGc7UfKb5TB5CGd9
         Y9v/nS1cNjYaVNB+s7qDxs8k62ui617lYwzEPf/aBwwfZV5h5c8eBmFLnJAq3CRmDiCr
         EvU/SQj3fCrV808Mgf1++AOGdKCvlSCCP97+XCsE/1OaYHCFPXlBlgqhlrQPhAaXKRhz
         jlljzP9NInU5LfL5VJJK/1XDJmmdBohYM5xIxF3BS6sz73Op989PJl7PmY5ScGvdRx1T
         +Low==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=J0UoNtyjlXHyau5OZuzM07Yy9QCjbo2q8iYtmMl1W4U=;
        b=HAvWO2YSBZk63iAvXuOhhzXx8tJbPXHCMc1AOsq59xDPHMBG5vGOXErzcYr97/IgPf
         CXKbt9JdLnh/w8lnQxxDcIX7WF88edtRtBYxVhRKh3kuoFW+4p0ap0bDolJ3vSfNMYJG
         tDv8I9XSuXLwLAwaQtoig6BLHGB17OVLsDKHf2cYzlySDQ4yzlvL6low10gXmgzuG3US
         k/TnBzYmT2wFT71N+RdU79auGXJhown5xuEruF88HOdh9qUjlpPXdnjGiToKz5Tqgptd
         pW3+6d6uOq3Fa2VWOiVRM1F+yqdJdQ3EDGXQljMk8i0zhMUPJPHNp3UUmD48tFvAFAep
         AgOA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k79si27375844qke.300.2019.07.24.02.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 02:07:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D9CE43179174;
	Wed, 24 Jul 2019 09:07:37 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.136])
	by smtp.corp.redhat.com (Postfix) with SMTP id D002E19C78;
	Wed, 24 Jul 2019 09:07:35 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Wed, 24 Jul 2019 11:07:37 +0200 (CEST)
Date: Wed, 24 Jul 2019 11:07:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Song Liu <songliubraving@fb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	akpm@linux-foundation.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, peterz@infradead.org,
	rostedt@goodmis.org, kernel-team@fb.com,
	william.kucharski@oracle.com
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Message-ID: <20190724090734.GB21599@redhat.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190724083600.832091-3-songliubraving@fb.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 24 Jul 2019 09:07:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/24, Song Liu wrote:
>
> This patch allows uprobe to use original page when possible (all uprobes
> on the page are already removed).

and only if the original page is already in the page cache and uptodate,
right?

another reason why I think unmap makes more sense... but I won't argue.

Oleg.


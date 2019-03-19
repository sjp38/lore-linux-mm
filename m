Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 323FDC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:31:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAF642133D
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:31:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAF642133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C2E76B0003; Tue, 19 Mar 2019 10:31:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64D016B0006; Tue, 19 Mar 2019 10:31:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53C8A6B0007; Tue, 19 Mar 2019 10:31:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B5396B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:31:31 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t4so8124357eds.1
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:31:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rCvJ4BKA+UDJ8OPRehUiY0/9BXyu9EcNL+cbKIXO4VM=;
        b=AU9f8pxTEtPk4Q9GYomaIg+SeeUsDAywemNfOetjGVMClXiJ0FNMP6T7xWnuo7ivGb
         B6OXka5tlThBNi/ZriKetjduIS2z68URSwhJFT7XJcAilsZkMcrN9ZQ/K6ju5EpIcS9q
         AHRER9WIHB97BuP3vyLGoH3rXRg9PRyyKjrpXn3Zocb5x0Zq3HFdecGTwsLHFhPaZgs1
         nJZLJXCrqakps5c+oFo50SxWRDRNEH5mHXDB/SwlXhBKwdb2eNqWnwnFdtCDQi8rvyWr
         mKQumxiOXv9yBMoTV5RcchJtWb4L/752uA8ukhPN7+dCf5GZ4e+cytV54WeonkiEz+a8
         FymQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Gm-Message-State: APjAAAX4ZI2e4D76nYgbwuLUznwqEtfqRY+SVtCHbUy0nCDmQh3iEbmI
	r+eHw8wqi4HtZOIfMki9WFgT92lyXlTikWqu7sLsrBPsejWq/NXkbyLqBmzB8pFfw5/foAblrU2
	ewAZQKZFtTfPns/hT7uuIkbdDahx4rIT+9+qJTVoJTmq8VlVWQRLNZgbx8B+iQ4g=
X-Received: by 2002:a17:906:88d:: with SMTP id n13mr14413345eje.154.1553005890629;
        Tue, 19 Mar 2019 07:31:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5LkR5B1Vcv9iMpAhujq3VbCaCG527ODoE5eaBOrjsVMs2qmEQbkcUmkxn4xUECLTe9LVm
X-Received: by 2002:a17:906:88d:: with SMTP id n13mr14413301eje.154.1553005889780;
        Tue, 19 Mar 2019 07:31:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553005889; cv=none;
        d=google.com; s=arc-20160816;
        b=B+DxWhoig7eFrdyxs5tDBLHX2k1AENlbWM0DSAlTLqGlmejzgTlljiFuuXLEGcbO4x
         ZB1BmkGV0sJp352hSAzjbj3ubZHEG2Q5Cga73G0pHAJvNXJHCkoutzQw5vk7AXdbM87z
         036B7ARPYTW1EWGjOCQwvwlxzBLbY83ApczG6zm60WkU5EXRC18SGavdO5jYQijZ+M7Z
         nbsvRXaSp7XnPRYkIvik6F593T2RCIDe0FBMxlqmSIbsSKaWKckfPQWv7ux32Ae+z5d5
         6uvVTYjb/LCAyt3RsPYEnHpxh+psQukLVT8IHfa9nAoOePXCphSAUbi/NKh2JfITrIb9
         dVJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rCvJ4BKA+UDJ8OPRehUiY0/9BXyu9EcNL+cbKIXO4VM=;
        b=Gk/PT1hfemdf+4lPglUgLtub5YP+Om7x/QF8qxgauUdkB/gIO6kmkDTlLTPKvoM50E
         OUnWMX4uGlPI4scmjGXfIXfRbTz0aYbwvmvl4c9GNXogwayRbLN2dNvS6lkSNUDltwbw
         /LB/Wtv6VW81vt6ahRrf8qXTs4u9hzskE9UuNUyFbHMnlNI4I5CRtVuIJGQFOJEEB0ST
         DM8oCHdRgUWfzNdaRZpcDOnHY/ciINCP0DGz4ZzJl5DGkQsSeMGZGvLdnEmSL7/OsiL1
         KatePg8K07hJNcMMkM5iHSZrzrooyLUXXwKk3nRqU5pN363YbBWbAVfHDFbWa9hA1XaO
         BzIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v56si3332764edc.339.2019.03.19.07.31.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:31:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4418FAFF8;
	Tue, 19 Mar 2019 14:31:29 +0000 (UTC)
Date: Tue, 19 Mar 2019 15:30:43 +0100
From: Cyril Hrubis <chrubis@suse.cz>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Oscar Salvador <osalvador@suse.de>, Yang Shi <shy828301@gmail.com>,
	Linux MM <linux-mm@kvack.org>, linux-api@vger.kernel.org,
	ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>,
	kirill.shutemov@linux.intel.com
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319143043.GJ6204@rei>
References: <20190315160142.GA8921@rei>
 <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
 <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000053, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!
> That's all sounds reasonable.
> 
> We only need to make sure the bug fixed by 77bf45e78050 will not be
> re-introduced.

Well, we can turn the reproducer from that commit into an automated
test, that's the only way to make sure bugs are not reintroduced
anyways...

-- 
Cyril Hrubis
chrubis@suse.cz


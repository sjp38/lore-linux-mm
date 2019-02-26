Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D9B9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:10:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 420D221850
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 20:10:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="szj5Pezo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 420D221850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBA508E0003; Tue, 26 Feb 2019 15:10:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6A198E0001; Tue, 26 Feb 2019 15:10:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5ADC8E0003; Tue, 26 Feb 2019 15:10:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 86DB48E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 15:10:42 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id e1so13099706qth.23
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 12:10:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=PVAJQc7zm0/UuJ2/28R2Kg+xhez7CklWKF4FR40pHt4=;
        b=loO7ZnsVCgHUxOlEcbUiAEtQxdKD2oMxC2Zx98w6CQn20n8WZvubdRGykv6lSRhfa4
         Ry/bLM77sSCJHcwqZqVA5btB9UqI+oaXw8CXVZvK/TkCLI6bTUV6FFWXCSH3V2gNOFHs
         Nj0jkGR6LQf0pl40wGBSVC8N5cSZWt7G6x6q0oVkyP/xQitv/ZI77L3pHV1bxQHutC3J
         YRXAp8IhZ91sP2h3/9jbkwTlMqIybZrHfWLF41o/7cSO739Ko07e59MjD4BLT2dNtdVZ
         q73xxmLfD9ehe/H3JC6zpU2MRzis2ZhZyiCIZ4n96NAbB06rS8ZQARaTxOkE+JwGrh57
         efRQ==
X-Gm-Message-State: AHQUAuZJxB+RmeYGOJG3YeDMNGEuv5AIIhXWH3bxjWyS9jc+zp5pfdhk
	e5jn/HXefx0AlzKS/CUqYXwoYFEJqE2hHVdbEZsq7EyTQg/IWmrIHLpIJG1k6hHC+MgtentFthL
	7bP2+4kV6i9i5QfJYzRPAlDV8qnRnDbtNA8hXvWURhu3iHGo1SG3aahKEq/vVLRKNOUGcaz+iSJ
	5kxj8Hih5a07+Bmxw6rLGjW8lnejftt612fRy9HT/l13RmemN5OhCs6aIib5GC3Xb4VyxWfdr8v
	sk28Bk9C73i4RzqKo/6R8T3EpmQCkNHKMySSiU8lhcqWgmpGkb/wBnmnZDNTRhCBPAwV3Pnrln+
	Oa3QmXhWGBgUyFLF82WcnHwHnYaRy5kaDrToVu/DQHAFdF+RdcIWrUbXr8kbneAJz1RXywkmen/
	T
X-Received: by 2002:a0c:94b3:: with SMTP id j48mr20031766qvj.189.1551211842233;
        Tue, 26 Feb 2019 12:10:42 -0800 (PST)
X-Received: by 2002:a0c:94b3:: with SMTP id j48mr20031717qvj.189.1551211841397;
        Tue, 26 Feb 2019 12:10:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551211841; cv=none;
        d=google.com; s=arc-20160816;
        b=jsDfDCYNk1BxyLhwPHYWF/tWr85R73+yXdIbVfzLGCzxldrUQGQgS1rg/bbP6xUs9F
         8O4fTd8JOdbmQwCoFO7AThNlI2xYz73rp4mRpNw25E1p7k/YV8Hg4C7DK1SItG+GVKvJ
         kbSVCTTf8T9h5ZpuZU1FQl7WJl3ZmIDILmRrzyk8/bvgpNueK1vHj1NBMA3pN3SGOO+0
         6/mV/s8ny7CDjF4y6PKLRT0pL1WFFwwSO3nbcwOEC9zK37FPeBoVfKHge0YQlMl/7zVK
         BKHUCHUUOlMrxHMmYoP+YXTIqaD0Zj4KfuAXnDo6RSN2Wq/rro704ycZZLAR7I9sewRZ
         rsHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=PVAJQc7zm0/UuJ2/28R2Kg+xhez7CklWKF4FR40pHt4=;
        b=b8mK+z2/9zj5mbBWywacUF2GAQAARKwtNA1ecT7Z+7ud3isqC+dMlCaX8VpmHbrIrL
         rDHyz3veA2WbPfCbrQqNFDrkxhP3U5aCrkwtd07JJ7jr1nNMDHcl7DZuLFyxRbxHFtEN
         wFnaG5KxPLfgXv1Y/qinLRzOBvjzctBSX8rwznBsYfPv7pX90KuoDY/Nc5jrNQGbCHA2
         Vn/o4qZ42NmFxvB7Vs2R/DIs8to6hw90hubnOM4J5kIuWJrwGEFXnaPL68f0+zDtpmpT
         CJz6jRrIn30TFi66xVSGG1+jrr27ps62C74JJtDMMqxgOB93mLX6LzvdXbDg8SkNTtci
         7CTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=szj5Pezo;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d26sor16734686qtk.40.2019.02.26.12.10.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 12:10:41 -0800 (PST)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=szj5Pezo;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=PVAJQc7zm0/UuJ2/28R2Kg+xhez7CklWKF4FR40pHt4=;
        b=szj5PezodOf6fy3TTJDCb6FuY6gx5NlIo+SgoBO/yoy5OIf2REWokCmVLNRLNJfxTM
         1YEvAwiY0UrzkPyP4CJyioVjKN/ZSwAVg3cZuyD655dSus84GhS4wib5eYKNvoI1LOVf
         U1cVfPgANCdKx7TlRkWvLhHC1fzhIBb3l4o8TnB8ys1FFGF96iZPXNYOvzBDcNO3boOd
         GB1I8yhCfwx9cI9K+wugOHBVzlVsEb2B2FfaPTDulHoDK6uI+ExJ3ynEtzqo3AnTAtGn
         H4s+cZu4VkBVNsBB400YQmvV3uBH1COFj6aBNxOB/Z+zPnRcsjWJkc/nk+PLDE6ceNPB
         qJpQ==
X-Google-Smtp-Source: AHgI3IbwIASi1Yl1POT27rifla4p+mkrU+55VCWmojDk/BpmEDuBF3muTAszov9c9OLMp6LXHLjHzA==
X-Received: by 2002:ac8:1b6b:: with SMTP id p40mr18870589qtk.155.1551211841157;
        Tue, 26 Feb 2019 12:10:41 -0800 (PST)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id m128sm7927982qkf.53.2019.02.26.12.10.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 12:10:40 -0800 (PST)
Message-ID: <1551211839.6911.54.camel@lca.pw>
Subject: Re: [PATCH] mm/hotplug: fix an imbalance with DEBUG_PAGEALLOC
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Date: Tue, 26 Feb 2019 15:10:39 -0500
In-Reply-To: <20190226194024.GI10588@dhcp22.suse.cz>
References: <20190225191710.48131-1-cai@lca.pw>
	 <20190226123521.GZ10588@dhcp22.suse.cz>
	 <4d4d3140-6d83-6d22-efdb-370351023aea@lca.pw>
	 <20190226142352.GC10588@dhcp22.suse.cz> <1551203585.6911.47.camel@lca.pw>
	 <20190226181648.GG10588@dhcp22.suse.cz>
	 <20190226182007.GH10588@dhcp22.suse.cz> <1551208782.6911.51.camel@lca.pw>
	 <20190226194024.GI10588@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-02-26 at 20:40 +0100, Michal Hocko wrote:
> It seems you have missed the point of my question. It simply doesn't
> make much sense to have offline memory mapped. That memory is not
> accessible in general. So mapping it at the offline time is dubious at
> best. 

Well, kernel_map_pages() is like other debug features which could look
"unusual".

> Also you do not get through the offlining phase on a newly
> hotplugged (and not yet onlined) memory. So the patch doesn't look
> correct to me and it all smells like the bug you are seeing is a wrong
> reporting.
> 

That (physical memory hotadd) is a special case like during the boot. The patch
is strictly to deal with offline/online memory, i.e., logical/soft memory
hotplug.


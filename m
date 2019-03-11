Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52D2DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 15:21:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1303C2084F
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 15:21:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zdOH4ynL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1303C2084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9367F8E0003; Mon, 11 Mar 2019 11:21:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E5058E0002; Mon, 11 Mar 2019 11:21:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D60C8E0003; Mon, 11 Mar 2019 11:21:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3ACFA8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 11:21:19 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a72so6470857pfj.19
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 08:21:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=vaSnEnlw/TVlhOOo/8HNFtQkbVQ+NguRfnY9NJe4jkI=;
        b=VbdMCQwBULRYRIyzGnQkWprkhHZ9IPS4hmWi3Hm/IA1uwSEwRXDb7UoTwhMA6Ifpee
         C30EGCQ2IE23yvAx8JdVF1hMzwE/LtKjYYqPSebAmBAaB2cy5G/LMOI8wJGa4UvB2KtJ
         YxEPiEminhGMNI2c/ulFu6vpy4V8UcCj8T7vbbmQ52pWuFWI9Drg91PsENro73+E9pfo
         fpNQTQSe0/gHUe4UN0jecxdV3njqPBATaznbYykw2HHWJOewJDTHiyM/Hso32dDijrIf
         kvrMG+KBZp/kd4GC0s30YnhEeY0kTkRK21jlVHj7cZZ4Gpj892QviwH0f0SgCcjjUwvp
         RxgA==
X-Gm-Message-State: APjAAAUiJNQEOUmQEaRN/qnsPAiDN0vOX+X5HYsvX/U3M7w/9PsDte1K
	4vxnwO3cJmb92OUZnI6V3I8JdV+6I4YdVJ4uMky0sLzkdYkobW/B8UVdTYdHzt/YBpC6mRZp6ej
	/VFkzIDnMuPGxvNPYvpPGMPatAx5LeV1jo4PABCTEYxyAEdR9bZQMnc78v62/EmVtmQ==
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr33653904plb.199.1552317678827;
        Mon, 11 Mar 2019 08:21:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzIht+YotDruzaFGqQw6vWDdpbjZGXKB76az6WShn3I+5Eb8TfFOmdlyx2cPlZHUcrZxc3r
X-Received: by 2002:a17:902:f095:: with SMTP id go21mr33653817plb.199.1552317677521;
        Mon, 11 Mar 2019 08:21:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552317677; cv=none;
        d=google.com; s=arc-20160816;
        b=Sy+4hRHOfevcihOSNDw/u8l7GLLDP317Vvt2JQnmZQraOav0PQ8vwbyOKLN6cZpcdq
         MT+XXHa1kzCmyqHXIR9v1VvTFYDbHWBnqOdTbdXB3ZKsQSYtWj0BPa2jbtothptHGiCb
         k3nkeloHyyVL14eWO2kKsH6LeJb+OA5IaANOKT2YxhES8GHYoZ7R7couPzdaKIfkwYOJ
         xXSkJRgzvgBYdZBIqyROtjNzxCowObUHliPsR1MUwpC19ikrXauAOcNstj7LL59y9ZPY
         BggFs93Gl38Npx2TwKBxMhO9YecJrnLaD+Ipc7rSvn1adc2KjwqKuth7rL1qg/uLzP4+
         A6Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=vaSnEnlw/TVlhOOo/8HNFtQkbVQ+NguRfnY9NJe4jkI=;
        b=xVNIrXywh2edwsA+R1yLCm3uh5miD4604r49JJ9I2zR2cCEnlBkR3p/ZgPepOwbyXO
         gCGSgoZZveexeDMa/gEcCYftqg3MOz2ZDLr3V7255Z99swrF8/mHTB5hRGN7wM1zDbTp
         n+IMHlYggv97ujPvZAabNR4cpilUv5iUSjjy8QwClSOMTpe4ljpgDb2Wfk9aiCgZv00B
         azOLvxJd3E80t1SKs8JYoYhjjVPnyOrIpWYY0OqMvsEgkI0rSLTma+88jcCUmg9qPvMc
         6aZeGzlyiHEiTqEVBjT0s2WuhDJ0vsKQD9u8P06XFrzaWPDDDtHwVsgWSDkWixKZqQWf
         PBvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zdOH4ynL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n19si5202373pfb.189.2019.03.11.08.21.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 08:21:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zdOH4ynL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id B1A85206BA;
	Mon, 11 Mar 2019 15:21:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1552317677;
	bh=GyN8CIJ5eBdr7RQPXWWiMKwbfzvTOikxhhQpmshZwds=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=zdOH4ynLudvXY5u+bZM1qCkd3t57ky/BexK0tzCKajQxvA3YQ1W1AJlqAbqgMdqqw
	 ceJIqluwIEK9FaBHk2Ci3mv9ItA11cgXlzF27cOn1g9W8ZtQ33b36DGV9ZJjB2xy+c
	 BOx1M1O7n+PtHyMXQsXU0Y5HA8xH3ocQjeQ5oOTU=
Date: Mon, 11 Mar 2019 11:21:14 -0400
From: Sasha Levin <sashal@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	Michal Hocko <mhocko@suse.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH AUTOSEL 4.20 66/72] mm, memory_hotplug:
 is_mem_section_removable do not pass the end of a zone
Message-ID: <20190311152114.GD158926@sasha-vm>
References: <20190223210422.199966-1-sashal@kernel.org>
 <20190223210422.199966-66-sashal@kernel.org>
 <20190226124649.GH11981@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190226124649.GH11981@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 26, 2019 at 02:46:49PM +0200, Mike Rapoport wrote:
>On Sat, Feb 23, 2019 at 04:04:16PM -0500, Sasha Levin wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> [ Upstream commit efad4e475c312456edb3c789d0996d12ed744c13 ]
>
>There is a fix for this fix [1].
>
>It's  commit 891cb2a72d821f930a39d5900cb7a3aa752c1d5b ("mm, memory_hotplug:
>fix off-by-one in is_pageblock_removable") in mainline.
>
>[1] https://lore.kernel.org/lkml/20190218181544.14616-1-mhocko@kernel.org/

Queued it up, thank you!

--
Thanks,
Sasha


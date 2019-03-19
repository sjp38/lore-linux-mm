Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 138C5C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:08:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3CC82183F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:08:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="OppUbOy3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3CC82183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5EC246B0005; Tue, 19 Mar 2019 16:08:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 59B186B0006; Tue, 19 Mar 2019 16:08:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 488E76B0007; Tue, 19 Mar 2019 16:08:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id CF3D26B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:08:01 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id h15so183169pgi.19
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:08:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=o4UyRz6g93ADtjVq/HClaAK+YTpkWMBIqC7PYkximTE=;
        b=tHCGIwZNrmXjIzKqYMQOPgYUkr0CqKACQMMR3Awi8YSVD8w0sos+QpQxSbiaWq/vnz
         1EyUCzBIREr9k4PQLtTyM5fL7r55dydiGQ+Yb2TCfnq81ODmDc4+AY2iYtPNNYo+me5Y
         eHmabuMreHTOyxO9VjSMMWfE+YoT2yJe6dfTFdSByB8xIyez9PdJO/t//MAp7EFsb/tM
         3jmgC5u3NGNsn1xlW2GmE7oMUbNvNLHbjxpbh0XaZpyogp1aw8rdc6vZoODGlxGQFlom
         MUDEiOeWcu1NdLTiTfMzzEqlTqM+XFWOwBi7Vs2ZDN2XuJAllxd9p0p9SEUPjLG2wWlO
         zKUQ==
X-Gm-Message-State: APjAAAX6ANmLGXUexiWV2GnrGOzMQJeHHBQ/du9FLQxte+7MO5SKP8mx
	pGXVRQ0sp8JFG9Ofutl5f0Wef1qn782kRCRDHeiR+Oa6+ejqs4o7qpbzGQXJ6y1B1WHMSuHsmWH
	UEJRtJpTDl/bEmxfGEMR688Bi0QUQ+58vISWFDyLmwIpf70l0PP1G4IcHnMUJ7GQByQ==
X-Received: by 2002:a63:5321:: with SMTP id h33mr3678023pgb.168.1553026081504;
        Tue, 19 Mar 2019 13:08:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzyhNtyf/bsWiyww5k8ADi07ycXuB8O7NfU2X+m1M8qjHY8OsjZlIyRSUdX/uu7MNf29mL7
X-Received: by 2002:a63:5321:: with SMTP id h33mr3677967pgb.168.1553026080638;
        Tue, 19 Mar 2019 13:08:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553026080; cv=none;
        d=google.com; s=arc-20160816;
        b=h6Fc8MsCWZ8fakGpLzy2Ta921guy+wEPGEpt50OjySfqGmp3iS8q27NvBpCm+c/pj3
         8S3xHkx0ssvgUTAsE0ZVBzEpQZ+I8CQIJaESy3BpceUfniFeZQQ9Mrrpbxbyy5qQ7ea2
         65w4iB4NEyViTBsXgrz62oNL5nfMVYhsg1MwlUmM+0t8bZCqvTPRHDa2tPhAERuN0kwc
         gfNKxeh7yfOq6CyHdg5RdZtQOif6FxBwqGQ+y3+IvkuUa4BKFC20p0n6OHeR98L1u61t
         +AghdqAiLvl15pIsuRVdktq4CBkNB1o6o7WfkCrXMAoyFWCoRBFl2w5FTHa92dcsKV5t
         yq4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=o4UyRz6g93ADtjVq/HClaAK+YTpkWMBIqC7PYkximTE=;
        b=dc9fiB+5qHQERIS/zOBKTUG/1u2WFMsahViXLDp+JCu/R5H3JsQNHeIW3iTqx2/jyO
         vlUlv15pXRll6V9sYOA28V14tmqIBqRooUg5KGhtNRK7a9cmP2Z/yfLIxUHNeI8k2qc9
         /vPqqgNJfoUjQaZjfDpxO+ycbQIO1eTlNex3gDjvOtBXkMSJobW9DqRFwazvaiAvP1fl
         59DWEzf6eB/UbLhdNytDDdsJ5wUYTSUH9RsU/25COhHF+hoKH0353HL9YH10zo6VV8UL
         Rjx1Waw62LRLsuuFuLwCmTIDPvQcBY04sb6uahtHF5Ns3X8ZLL6uAKe7xUW8XTV0yhuL
         3T3A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OppUbOy3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 14si12086570pgl.479.2019.03.19.13.08.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 13:08:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=OppUbOy3;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C72692075C;
	Tue, 19 Mar 2019 20:07:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1553026080;
	bh=o4UyRz6g93ADtjVq/HClaAK+YTpkWMBIqC7PYkximTE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=OppUbOy3Yxbrq4Ejx3FzSarYWcNIqYpa6VwBHrlz+dGVfK6C4cyxs83eorktVVnV2
	 PbzVWpCwhCKkXVHeuldE1Y+FduNIXlXq48fi0qYq9rKQopCv/JD7T7Xa9rpUFhTIqj
	 5GE+qs+Zmc13CTOGhSDvHc+go1wtk3nx5JMWo8uo=
Date: Tue, 19 Mar 2019 16:07:57 -0400
From: Sasha Levin <sashal@kernel.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org
Subject: Re: [PATCH AUTOSEL 4.20 37/60] tmpfs: fix link accounting when a
 tmpfile is linked in
Message-ID: <20190319200757.GB25262@sasha-vm>
References: <20190313191021.158171-1-sashal@kernel.org>
 <20190313191021.158171-37-sashal@kernel.org>
 <alpine.LSU.2.11.1903131248210.1629@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1903131248210.1629@eggly.anvils>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 12:58:26PM -0700, Hugh Dickins wrote:
>AUTOSEL is wrong to select this commit without also selecting
>29b00e609960 ("tmpfs: fix uninitialized return value in shmem_link")
>which contains the tag
>Fixes: 1062af920c07 ("tmpfs: fix link accounting when a tmpfile is linked in")
>Please add 29b00e609960 for those 6 trees, or else omit 1062af920c07 for now.

I usually look up relevant "Fixes" tags right before I queue patches up
to avoid missing things that came up recently.

I've queued 29b00e609960 on top for all trees, thank you!

--
Thanks,
Sasha


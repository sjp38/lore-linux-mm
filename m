Return-Path: <SRS0=Hl4p=TW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0B67C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:19:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C4A92173C
	for <linux-mm@archiver.kernel.org>; Wed, 22 May 2019 18:19:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kxch2P6y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C4A92173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F2836B000A; Wed, 22 May 2019 14:19:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A1E86B000C; Wed, 22 May 2019 14:19:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B79B6B000D; Wed, 22 May 2019 14:19:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D967C6B000A
	for <linux-mm@kvack.org>; Wed, 22 May 2019 14:19:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b69so1832304plb.9
        for <linux-mm@kvack.org>; Wed, 22 May 2019 11:19:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=plhvxM4Kt42KsXzRdv9sakIOM8r+BM/h881KdHN1PR8=;
        b=nENBQGQglR8TWWsn8fu1nK0GsfZqFHlpzIao2S/bhHuw18eG2Q6DTk+M4d0lI6bAbG
         25oSWphDOvpUCenvid8bb0R10gNP0f88sT6gpInlRQZKzRTTwOmlGJB4Yoz3nMvI3aiC
         UX5VOmnr+Rf+GYRgKC5MD7hgfHbx1vfZIjGzVii6pb4+llwuEkccOP+ljseA4dMacMZ6
         qz6A2elIg8igoP7TYb31UAi8BGmbX9FFVpvA5bAcmQ1MjCGFJNfVh+hCfX7RAeWj+y2J
         CI/vv2COEDtBxC3oWpQ1y+Bu071NqbpdR3AXoomsLkAuGS3UVsXWYZiyrKppafNYT4sp
         rGzQ==
X-Gm-Message-State: APjAAAXxENzYyaEyJUbNhHOzdV9t5d+3ciog5qnIvACv+R7Wce2tcMxK
	7Avw357Lyxf7TLXoDlqs81OpSsSmmnZdYMF1onb2S5J+hOyW180ke7mK8Wz1mSQI8rJZkO32dbB
	58cDOB+8ov9jSYvwbohn4Vrwy7Jy+Klk/YTLGGj+Lbm1oZ8zwORyRHmq5BKAOlItU0Q==
X-Received: by 2002:a63:4852:: with SMTP id x18mr78478038pgk.14.1558549153491;
        Wed, 22 May 2019 11:19:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwh0/R59BBznM9xJ8ezpm5LaX0teFxy82oCIY1amgFo8rYBgz6pGmET8Q6GKB2VSuFmFj2K
X-Received: by 2002:a63:4852:: with SMTP id x18mr78477968pgk.14.1558549152779;
        Wed, 22 May 2019 11:19:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558549152; cv=none;
        d=google.com; s=arc-20160816;
        b=or1uDF7QdydK11yRehauiAUW9/8Uut5/AhcCbNRjcqCwgGYVHUskNnxzY+uTJz+Lbi
         Eb1/sEpSIYHrQVUgSENuYilkR6q+5G4zR3TByWscpK9C/E7ZB/tsmRihJYkiQ1cjqFUM
         PuhCWpuJdqKgqBLJ8rbo9pJr8ZhWdbv35JUl6RNQ9EV+7fcpLi1yy0HTlZ/ftH1ZgPYf
         kRfHSQgq6r5z+Hs9UdxngllfbiTmmtZ0UleFFZT0JvkAwED4oznwVA3J06X6+uAzC3xy
         tOrv94fTxlulMQwmJrFYeKzfTgbMV+jjylw1WWlgsg2acewoCKGGGS2YEfaInZdWDsZf
         Zdig==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=plhvxM4Kt42KsXzRdv9sakIOM8r+BM/h881KdHN1PR8=;
        b=wN64YOzfoYWBlzivjXGVNCmIDQavp5c3OSYwYWWmF5fvsgiW9pOgtttazxWvwlDR6D
         0J1Ht2M7KnEYXF31xSicktxp6LgkPH3x626jN6AoOfymNgLJHT8OOv3b9jvCNFMDd+Rq
         /MjAXKtpadYM5HxWyny0Vs9KnUVHSSU/LzGdaNPcBhOiYHFMwbikGsvrrgmJj1FUVCCu
         wYnDkw5i6/LopB3ZRnonki1dPmJSOHjyHWDREfgMQ9/cb9j6P3nwx8KirRtEDrYSzpQO
         lgIz12fA1cxT2gQEZdU3X6MW/+c1EapG6GW34Ia7mFZLTibOxtiXBxgR0w1OS+2kTyu1
         CfXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Kxch2P6y;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id k187si16956980pge.593.2019.05.22.11.19.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 May 2019 11:19:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Kxch2P6y;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EC36121473;
	Wed, 22 May 2019 18:19:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558549152;
	bh=Lj+UQSKOBWjtRSU8mmwyChOpiwRlOQuuXNdlNMg9qOk=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=Kxch2P6yoqn2ghOf6Zu5Akc+n+E7NcUW2VuwDGYxynrln25xvzIwwgleLCMAr+Cjd
	 dOpYDPHt3h+O0vEg9NqJj5RIaRl7eyVLSzCnpO2BOAZoeObsWf7Di/S85ZqKLTBoEt
	 zb5wpD9kIFFS/2atJeKvU6VaVWp18Dac0S4xG92k=
Date: Wed, 22 May 2019 11:19:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew
 Wilcox <willy@infradead.org>, linux-mm@kvack.org, LKML
 <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>,
 Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>
Subject: Re: [PATCH 3/4] mm/vmap: get rid of one single unlink_va() when
 merge
Message-Id: <20190522111911.963fbb4950e051a35e92887c@linux-foundation.org>
In-Reply-To: <20190522150939.24605-3-urezki@gmail.com>
References: <20190522150939.24605-1-urezki@gmail.com>
	<20190522150939.24605-3-urezki@gmail.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 May 2019 17:09:38 +0200 "Uladzislau Rezki (Sony)" <urezki@gmail.com> wrote:

> It does not make sense to try to "unlink" the node that is
> definitely not linked with a list nor tree. On the first
> merge step VA just points to the previously disconnected
> busy area.
> 
> On the second step, check if the node has been merged and do
> "unlink" if so, because now it points to an object that must
> be linked.

Again, what is the motivation for this change?  Seems to be a bit of a
code/logic cleanup, no significant runtime effect?


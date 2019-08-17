Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FDBBC3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 06:36:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E0720880
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 06:36:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="TZa25lqN";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xeRMLb3M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E0720880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 391276B0007; Sat, 17 Aug 2019 02:36:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 341766B000A; Sat, 17 Aug 2019 02:36:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 257506B000C; Sat, 17 Aug 2019 02:36:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0078.hostedemail.com [216.40.44.78])
	by kanga.kvack.org (Postfix) with ESMTP id 0653E6B0007
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:36:22 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 86319181AC9CC
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 06:36:22 +0000 (UTC)
X-FDA: 75830960604.03.waves39_71c876a04dc30
X-HE-Tag: waves39_71c876a04dc30
X-Filterd-Recvd-Size: 5606
Received: from wout3-smtp.messagingengine.com (wout3-smtp.messagingengine.com [64.147.123.19])
	by imf16.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 06:36:21 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.west.internal (Postfix) with ESMTP id E6AB84A8;
	Sat, 17 Aug 2019 02:36:19 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Sat, 17 Aug 2019 02:36:20 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm1; bh=Y9OfE2r4E1tSStdiznC+SPSctms
	ndu3EzLvP6c5/UhE=; b=TZa25lqNMX0mP0RXq2uiix8rthdUBWVqAyWlAiCwIOC
	DuBWbIJQjEqH0t8I9ZI4MgBqQ68VVjSyIWBup120UpcrEb/JSfdbiIwBqhqgqxeL
	eb2BCFfMK2B0TLDP78omUF+7ae2Td3HdoQIEi4cZZb7sAUMgDY87hX3iEHrqYlGy
	7xGf9a5w7apuniEHIOQ7o1oDhWoXcv2kGbHKQc0FQMkuKSheUIZqy+Tv19o5QpPI
	tI9I7t3nwEeO/WBDm2m0aLDIZdR/Ud9VRc/n+8K9mgKDI597qBiqXSSIzbxflujr
	kEQ/9pt37URFO/RLTqziuiyTgABfFzAoluI2+rrLKDA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=Y9OfE2
	r4E1tSStdiznC+SPSctmsndu3EzLvP6c5/UhE=; b=xeRMLb3MY3vBZw/F8zOFnm
	a4VK+p7QYFIJf20SVMJiaKHvgk/0GWXQ/L26fnFrJTN422eDLzx2UnBEDYrIegAY
	im2q/G/ySaAR/8IYo+4ZmDUwYXzpcikzEmZPAxaFOJB4kwFbfoqEIixa7o1NpHUH
	QFfGdUr0SB+Umkhg2gFWj5amFF6OkXCEDV1jkyd1/QKsrYyA/CChoIi6ePHaRvBK
	A2KCPmCjXen+//oS488T2tEcCxCCbISTnip5wjHtlSuntIJBq/znpxQQiHJzlCsM
	q+y/XV2DerUUdEj2H/XkkkiUpWVWvONcYHcG0V/HG+4mQq77zWeqzqMWWS7oT2vw
	==
X-ME-Sender: <xms:YqBXXbrByT9GOXZ8IYWnQTjbQ2YmgJNUju-HvcEyUtjYq_irrVs2LA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrudefgedguddthecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfgh
    necuuegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmd
    enucfjughrpeffhffvuffkfhggtggujggfsehttdertddtredvnecuhfhrohhmpefirhgv
    ghcumffjuceoghhrvghgsehkrhhorghhrdgtohhmqeenucffohhmrghinhepkhgvrhhnvg
    hlrdhorhhgnecukfhppeekfedrkeeirdekledruddtjeenucfrrghrrghmpehmrghilhhf
    rhhomhepghhrvghgsehkrhhorghhrdgtohhmnecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:YqBXXc4ERhLhe6tpOAsvbg7g9hIVq_6CZUqNjs1hPxZB33kP4769OQ>
    <xmx:YqBXXXvkaO4hNrl6M7UDdUc8SwINCl72Vh_MndbqIPOzoZwUalp1mg>
    <xmx:YqBXXYBStRf1swCt9yJ3uAFkiARFiEqNvxud-pRIZN6vi0iC8fRlsA>
    <xmx:Y6BXXYKn3-vltsJBTcAS3uHziTQcTkHz1vQtE_MpHrdyM9D0qI0meQ>
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	by mail.messagingengine.com (Postfix) with ESMTPA id AC7AB80059;
	Sat, 17 Aug 2019 02:36:17 -0400 (EDT)
Date: Sat, 17 Aug 2019 08:36:16 +0200
From: Greg KH <greg@kroah.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Michal Hocko <mhocko@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, stable@vger.kernel.org,
	Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM
 counters in sync with the hierarchical ones"
Message-ID: <20190817063616.GA11747@kroah.com>
References: <20190817004726.2530670-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190817004726.2530670-1-guro@fb.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 05:47:26PM -0700, Roman Gushchin wrote:
> Commit 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync
> with the hierarchical ones") effectively decreased the precision of
> per-memcg vmstats_local and per-memcg-per-node lruvec percpu counters.
> 
> That's good for displaying in memory.stat, but brings a serious regression
> into the reclaim process.
> 
> One issue I've discovered and debugged is the following:
> lruvec_lru_size() can return 0 instead of the actual number of pages
> in the lru list, preventing the kernel to reclaim last remaining
> pages. Result is yet another dying memory cgroups flooding.
> The opposite is also happening: scanning an empty lru list
> is the waste of cpu time.
> 
> Also, inactive_list_is_low() can return incorrect values, preventing
> the active lru from being scanned and freed. It can fail both because
> the size of active and inactive lists are inaccurate, and because
> the number of workingset refaults isn't precise. In other words,
> the result is pretty random.
> 
> I'm not sure, if using the approximate number of slab pages in
> count_shadow_number() is acceptable, but issues described above
> are enough to partially revert the patch.
> 
> Let's keep per-memcg vmstat_local batched (they are only used for
> displaying stats to the userspace), but keep lruvec stats precise.
> This change fixes the dead memcg flooding on my setup.
> 
> Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Yafang Shao <laoar.shao@gmail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/memcontrol.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read:
    https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
for how to do this properly.

</formletter>


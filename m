Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D74EFC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:21:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 80F5921734
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 01:21:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="U20wl/Gn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="5q3b5ahU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 80F5921734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC7798E0004; Mon, 11 Mar 2019 21:21:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E79358E0002; Mon, 11 Mar 2019 21:21:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D415A8E0004; Mon, 11 Mar 2019 21:21:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0F8D8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 21:21:01 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id c25so850790qtj.13
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 18:21:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MzFQnSxojSJGZnBAYbVx8/TBuxAbv7N2dzpm+iEloDA=;
        b=jwI8Bn+g9M+d0NFzEX4Ri9snwzN5MYMlqgqVRNEqraU2m4kXjztc7h7ZlEk06JoROc
         VjUIMPfxhs0dxFSIPUCfGIfLQ9xFYr1C/roh5ZwUAcF/rS8Rc5jGGSdo2J9TRX8YGKOn
         CfQDvTnkzXggfk8QsAwWxJd+QKGwfybLuxGYjLf7aTWjMPUUBmryUGuV+5y07uQo9qN5
         8eG5WzniadlfmaR6e9ZgkgL0UeMdTDkKEsrw9qO8OBHTtY1KO1PQ97sv5Ix+/O/In4Rd
         RWhmNxF1JMMUwF/UyEPzRPxySb08s/QDmWq9nX04qMM+D0gSBnaK3mp5eKqZZxayL0a9
         TMdw==
X-Gm-Message-State: APjAAAWpt92NQY2FMfAA35JStWktFSlA0E/u3Oq/4eHAQB/mUcM54IuL
	nDZsQAch0u8L8wZgEOi2Bt3s8T7is0Ufd5UGLNTLqN70t46TFY0mc4PbaUIDI8RiGBGpSpYiuc6
	Z8JRnIYLeH1wg8nbREBL9BL/f1BxDGR7mtEcsR6QbtMBAT5MIRF/gVRGrzlQfMU/MAA==
X-Received: by 2002:ac8:17ee:: with SMTP id r43mr246222qtk.169.1552353661411;
        Mon, 11 Mar 2019 18:21:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxioDn4s6a3OlYspEVvPz/ivHP+MmtgaVx0xTbZzIJQwye/DeOHwTi6/PrTCgTWKZReTTVQ
X-Received: by 2002:ac8:17ee:: with SMTP id r43mr246192qtk.169.1552353660723;
        Mon, 11 Mar 2019 18:21:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552353660; cv=none;
        d=google.com; s=arc-20160816;
        b=mMD/R2Y5Qze6LY2xhjMnP5Y/SpyhLotZ+HcB09ptE9zxzs03mwtGADSmvVcHlJpfxR
         joLOr1bwelSGfup3W06MfoNbautVZhkO5Xe9EA3MrPFoSA2vQ+OHzemm0mVT6URDhE5o
         4qrF6TS65OdUh6wf5wjsz8L+8515JQyRMZAoJkT2cXFvmLWCQl4EXvAsj0rkEHjbh1Pu
         WqRgT13d6Rae9vFR6WtXCkAVYro4IYmr2J5YklDnRYlJhuH6YDEK3NN74vo6ktW5Rj97
         d6+T70bcyGsrRN521vOIW4CySSBXBgIQoWmcYgLfQhytHiPLs5AZ6IjXQX4uP56AQdpW
         wgDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=MzFQnSxojSJGZnBAYbVx8/TBuxAbv7N2dzpm+iEloDA=;
        b=pkdIVzddhCxKUqVhsAB/MjEzBnWToDyUGbcUBg0Aa8a+cUzmIjKv2xlbmmZlnneP3j
         uCVfvIKD4VBTEZgKl22Lut30pwTVUg26poax5t03JTrWaUgRosNkzptXYe+bO75B9z4F
         2SqViRzMnUepPol+c4pKjXQsM/SJFWqjxvC8LpSFXzOiySr1qUpUHpcJHyks4oPp/PTQ
         t7ZPQ2aEqOg+ReS90/x0zdMYr/o+40NzJCfL4FBbnbKUp12/xHnvRljy8jOIizQwe7Xc
         CX8PKLMt0sAmsLBFNsjpwa12LBj7PHnetycSQpuP6p8Q6cO5eWFFLSR7Bfl5WZ/DMBf2
         YnJg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="U20wl/Gn";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=5q3b5ahU;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id v43si1428750qvf.100.2019.03.11.18.21.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 18:21:00 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.26;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b="U20wl/Gn";
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=5q3b5ahU;
       spf=neutral (google.com: 66.111.4.26 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 69B7621AB4;
	Mon, 11 Mar 2019 21:21:00 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Mon, 11 Mar 2019 21:21:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=MzFQnSxojSJGZnBAYbVx8/TBuxA
	bv7N2dzpm+iEloDA=; b=U20wl/GnbA+DhRERfEIX4096EPnBKloNeqVtrO48olZ
	MbqVUB/YytCjDkBfCEKqtBMREYEk8O01IqANpQ3Dvh7am/UJJLc5WAzpR9Xggd0Z
	TnnWq/kgZIRotlotQU/V0dQbxk8FAtyT6dVSsF0b/Ftyr1DKt++vIfFzHiYGyRMf
	K6w5qAWO/b7c4fnsrKAiKMDJNLsSryrOto5WKWM12o1FYP0X/kzuutNDcD9GXtWd
	2lMUsvMdfpZObH+4Nq3WqrdR60VVkBKrRcIEPvyZK79B8DGaY/6ZZ1Bc+5F0i4Nn
	wcqxAzm/OgMDsMcRKWH51oDH1NQpUF91uRJ8wBtPQXw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=MzFQnS
	xojSJGZnBAYbVx8/TBuxAbv7N2dzpm+iEloDA=; b=5q3b5ahUh6DllulQ4lEnhD
	Zp2k6NkYEMX2Mn4XdBaGtwk8OszHvQ8+FlXGcblL0JuQRmk2L+fEP5g0Ce8vyG0k
	NLX9z2S/r6Ir/JhImqb3/LATFF9kBv4uGweDQuL2+qstAVleME1FhN5Yt3C0ytI7
	n8xAlEj1IIqu/y6DV9VA5mc1pz4PB5DY+xVM8leBHcVQDDwFRsQttn2QJuynGCYR
	CqXz1FDufVl2Il2RPvx2/yH7Ye+VKhc7Arkve4kC6vUvtmm+bFjbFymnhhin0l+0
	bUNqvQrsG5G9xNcbxqOniPnt6PlH0O9kNRxLIQqlzx4lFizPwY63VVdEAsfXGO2A
	==
X-ME-Sender: <xms:ewmHXPMt3jy3UszpPEjEQFQn3CbvWS0vIwf9eOtXaTC9gxT4FZn_AQ>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedutddrgeejgddvlecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenfg
    hrlhcuvffnffculdeftddmnecujfgurhepfffhvffukfhfgggtuggjofgfsehttdertdfo
    redvnecuhfhrohhmpedfvfhosghinhcuvedrucfjrghrughinhhgfdcuoehmvgesthhosg
    hinhdrtggtqeenucfkphepuddvgedrudeiledrvdefrddukeegnecurfgrrhgrmhepmhgr
    ihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrhfuihiivgepud
X-ME-Proxy: <xmx:ewmHXLf-rF9x3iJDM2deh-RVk40rbloi68FzLuoNeR-zHSIZ5XYtmQ>
    <xmx:ewmHXG5sTWH6Uj8DD3AZTRzK_ns0_0Ll4T7Xb0QAMihAsifrvkVPqA>
    <xmx:ewmHXFsRI5x3Zjl3mjARThPpRz4ibOnsaJNhTIWucJr7oJVZ2aUlWw>
    <xmx:fAmHXGpfKmltBDQgAEj666WwjVPqRw_xYBTKlk1eJ-sytniLh7QaCg>
Received: from localhost (124-169-23-184.dyn.iinet.net.au [124.169.23.184])
	by mail.messagingengine.com (Postfix) with ESMTPA id 46AD2E456D;
	Mon, 11 Mar 2019 21:20:58 -0400 (EDT)
Date: Tue, 12 Mar 2019 12:20:36 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Roman Gushchin <guro@fb.com>
Cc: "Tobin C. Harding" <tobin@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christopher Lameter <cl@linux.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Matthew Wilcox <willy@infradead.org>,
	Tycho Andersen <tycho@tycho.ws>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC 03/15] tools/vm/slabinfo: Add support for -C and -F options
Message-ID: <20190312012036.GE9362@eros.localdomain>
References: <20190308041426.16654-1-tobin@kernel.org>
 <20190308041426.16654-4-tobin@kernel.org>
 <20190311215413.GB7915@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190311215413.GB7915@tower.DHCP.thefacebook.com>
X-Mailer: Mutt 1.11.3 (2019-02-01)
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 11, 2019 at 09:54:17PM +0000, Roman Gushchin wrote:
> On Fri, Mar 08, 2019 at 03:14:14PM +1100, Tobin C. Harding wrote:
> > -F lists caches that support object migration.
> 
> Maybe -M?

Seems reasonable, will use in v2, thanks.

	Tobin.


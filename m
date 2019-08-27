Return-Path: <SRS0=oLae=WX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76976C3A5A4
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:06:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A9652184D
	for <linux-mm@archiver.kernel.org>; Tue, 27 Aug 2019 17:06:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="kugD2vcu";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="qy9816xr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A9652184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9E9D6B0006; Tue, 27 Aug 2019 13:06:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4F4A6B0008; Tue, 27 Aug 2019 13:06:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3E3B6B000A; Tue, 27 Aug 2019 13:06:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0096.hostedemail.com [216.40.44.96])
	by kanga.kvack.org (Postfix) with ESMTP id B1DCB6B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 13:06:23 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 0D8DE180AD7C3
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:06:23 +0000 (UTC)
X-FDA: 75868836246.14.magic52_54c0f07753113
X-HE-Tag: magic52_54c0f07753113
X-Filterd-Recvd-Size: 5393
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com [66.111.4.26])
	by imf49.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 17:06:22 +0000 (UTC)
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 0A9BA22200;
	Tue, 27 Aug 2019 13:06:22 -0400 (EDT)
Received: from mailfrontend1 ([10.202.2.162])
  by compute6.internal (MEProxy); Tue, 27 Aug 2019 13:06:22 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm1; bh=5nkEIGxasqd/7yw+ZF5/COJl223
	XTMYfYLQZXHCUB7g=; b=kugD2vculIs2kPbSnws+e69oxwOX68Py+emRFuU2Tpi
	69UIOdyVuNbnsT5rmYJ8lLa8njewkBBoa4+zb4faEeDiV6wwLrjQuqvpWIRwzKhe
	cbAnXRnMME3laZ2tP3RBbq8fAcBA7Nsvqe5tRP06njHYRTbY3Sd/NBQBnw85E4mH
	XHZ7+Muukvc2XbLwRhRuJ/glDgBDjnhrVQjqivKu5bhV71W36DiAS+0Fye6lo+CO
	FW60sA1AsnHL6nv6FZDSBeBa66zyOrmVT8NHbL709TLUx1V2ithesWktuADUwNsp
	VShLiV50fqlWPZ11QNzjt8nxPCTgV8AB5TSNYvdgMFw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; bh=5nkEIG
	xasqd/7yw+ZF5/COJl223XTMYfYLQZXHCUB7g=; b=qy9816xrwDMcFVLZuL87eS
	RD3BB8UJ0myM9Ep0ruyj/gYm7dZzX0xX+B7JXFgH9IS68ZzjuCNDs7Dckm0XCROp
	cFr+nu2E1o2HnnlMrp0fw7tT6qbPYXuJCSEmcePffWqqiaxvjG5NfHxLAHnnJMzy
	sR3d8CyI/BAp6AvMTVvlKJ8lHq9HM9RtnWBR+6TI+eLXrlkMOA1ipSso0IZ4pqw/
	ZyX6v+w26CmLoC189kmDkOBCWf0g+ODLTSXROITWi1Iw4aeLxa7mX5vidTTgy9TV
	L8u4B+a3OlaBZuFoPwE8PG/4iEMdmtgW9ZxJLaG+1cNsk1Lbp56een9+78eVprBQ
	==
X-ME-Sender: <xms:DWNlXRCDJClRk-hEq5Qu42gb-Cc75xqggO8WMZ8SpDP3wmzEXOyLpw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduvddrudehkedgheejucetufdoteggodetrfdotf
    fvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfqfgfvpdfurfetoffkrfgpnffqhgen
    uceurghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmne
    cujfgurhepfffhvffukfhfgggtuggjfgesthdtredttdervdenucfhrhhomhepifhrvghg
    ucfmjfcuoehgrhgvgheskhhrohgrhhdrtghomheqnecuffhomhgrihhnpehkvghrnhgvlh
    drohhrghenucfkphepkeefrdekiedrkeelrddutdejnecurfgrrhgrmhepmhgrihhlfhhr
    ohhmpehgrhgvgheskhhrohgrhhdrtghomhenucevlhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:DWNlXVilDt5E0R5ztZo5WlU-TEdXYF55JTBu9hApuYUdfjKksMvuCQ>
    <xmx:DWNlXXbfqQVTr1eTL8zOopPat_2Kmwx1n_sMIMipMO2z58eLIEHSMQ>
    <xmx:DWNlXek5Uh-JxPhoye92UBH_ibOJyXa99Yf8L6e8fpPLDVT46Bo-9Q>
    <xmx:DmNlXcmjOdOwq3SzXLeHbGpJrqiJknWcxGrII7O5jpYEUNJxdN0vTA>
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	by mail.messagingengine.com (Postfix) with ESMTPA id BD4A68006C;
	Tue, 27 Aug 2019 13:06:20 -0400 (EDT)
Date: Tue, 27 Aug 2019 19:06:18 +0200
From: Greg KH <greg@kroah.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Thomas Backlund <tmb@mageia.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>,
	Yafang Shao <laoar.shao@gmail.com>
Subject: Re: [PATCH] Partially revert "mm/memcontrol.c: keep local VM
 counters in sync with the hierarchical ones"
Message-ID: <20190827170618.GC21369@kroah.com>
References: <20190817004726.2530670-1-guro@fb.com>
 <20190817063616.GA11747@kroah.com>
 <20190817191518.GB11125@castle>
 <20190824125750.da9f0aac47cc0a362208f9ff@linux-foundation.org>
 <a082485b-8241-e73d-df09-5c878d181ddc@mageia.org>
 <20190827141016.GH7538@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190827141016.GH7538@dhcp22.suse.cz>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 27, 2019 at 04:10:16PM +0200, Michal Hocko wrote:
> On Sat 24-08-19 23:23:07, Thomas Backlund wrote:
> > Den 24-08-2019 kl. 22:57, skrev Andrew Morton:
> > > On Sat, 17 Aug 2019 19:15:23 +0000 Roman Gushchin <guro@fb.com> wrote:
> > > 
> > > > > > Fixes: 766a4c19d880 ("mm/memcontrol.c: keep local VM counters in sync with the hierarchical ones")
> > > > > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > > > > Cc: Yafang Shao <laoar.shao@gmail.com>
> > > > > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > > > > ---
> > > > > >   mm/memcontrol.c | 8 +++-----
> > > > > >   1 file changed, 3 insertions(+), 5 deletions(-)
> > > > > 
> > > > > <formletter>
> > > > > 
> > > > > This is not the correct way to submit patches for inclusion in the
> > > > > stable kernel tree.  Please read:
> > > > >      https://www.kernel.org/doc/html/latest/process/stable-kernel-rules.html
> > > > > for how to do this properly.
> > > > 
> > > > Oh, I'm sorry, will read and follow next time. Thanks!
> > > 
> > > 766a4c19d880 is not present in 5.2 so no -stable backport is needed, yes?
> > > 
> > 
> > Unfortunately it got added in 5.2.7, so backport is needed.
> 
> yet another example of patch not marked for stable backported to the
> stable tree. yay...

If you do not want autobot to pick up patches for specific
subsystems/files, just let us know and we will add them to the
blacklist.

thanks,

greg k-h


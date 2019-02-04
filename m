Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A200C169C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 01:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CC8A2177E
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 01:35:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=tobin.cc header.i=@tobin.cc header.b="R7YB7UDn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="yq8K5vFq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CC8A2177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=tobin.cc
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A132C8E0030; Sun,  3 Feb 2019 20:35:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C2C78E001C; Sun,  3 Feb 2019 20:35:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88B668E0030; Sun,  3 Feb 2019 20:35:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC2C8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 20:35:57 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id z126so15185778qka.10
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 17:35:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fosNBr64j7N3LqvNeuUMYV4VjDMKlvGUlOdVmegIm5Q=;
        b=T8iE6PRDUus8VbuGwYVAzoAjrxz5zDWTlEjavbdcQuL1ZUi+izfhNrDWELYbJy1PZ/
         k/jeBYFYoeiZMOKo4KtzztrYbsi/elhWIlZxmpFBeBRFe1QqPTgG6hdyBRcpTgXt64In
         +0leAas4x6XGFDDsPlwCbm3ZQ9Kp/CORpbwNWBDKWw69yPeCSGIOeu7AfauUDCCFuZxZ
         NU/k3iw6vSB/TzT08OYt8KTFOcOABZ5SF1xJ24kVtJ4bacPQDyVkQhOocr8qaHHcHJUi
         tC4lbum9qLeE+Y/g00QGjq9YWzQbzzjEyZzb+7mw3h0NyTFah/BYfdVdMZs+6yvZp71G
         iBfA==
X-Gm-Message-State: AJcUukeCbEn5V01g39IlqDwd7UOgbcpvdDHXqqqfZLR/7taFLGUXl84z
	rTPN9QsFJCrPNyMpif/4MXc29XSuCZh1DbOHpKgF7T4EfDDaCPoLTCO8pKGhlUKtnojeCmB9MLR
	f6nmaOkP+1himhhKWeaw3HBymeNrpTF/5A/vgOAg3TgatCng3RRfbelw7YcwiFJuCuA==
X-Received: by 2002:a37:bd47:: with SMTP id n68mr44449297qkf.203.1549244157079;
        Sun, 03 Feb 2019 17:35:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7uvKjOl3DwFk3fJzfdsFnQl1Pq2iHOPlk13WWvw8tvksq4DTgbcLdidGIMkqiGbGyqs5qc
X-Received: by 2002:a37:bd47:: with SMTP id n68mr44449277qkf.203.1549244156434;
        Sun, 03 Feb 2019 17:35:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549244156; cv=none;
        d=google.com; s=arc-20160816;
        b=W78ULsVjRtQ7kxfdsz/0bH8dP9obgk/EHtT+fPs/f4+Ab00Ej+PK7iGCJtGx8qNzau
         G7OEX70G4qnmpO7lWR1zEH7WzvmwWj59YsLRvXZbF0sa6BvfE8A5AdRR277C0GVK5lrT
         irkhiYIAeIooacKMMKauGmpSddJn0txhaBsVnNYikEpeh/Bc/a9qWORUY6S0oO5FDQsx
         WJEBbofmaCg+1xwOxHRSqdGoNtakjQTmy/nXLKX4upRqj+lYD3wVi+7wHA1MRcyrbkMu
         aZXdqXtxvjih5FYrG4NjzKXE5t2L2Z1jq/4iiP7P6F/c7Tmwujw2WvuBsf6btUl9taQa
         EvAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=fosNBr64j7N3LqvNeuUMYV4VjDMKlvGUlOdVmegIm5Q=;
        b=NVp9zjSi2LvYrx7VL/l9PK7IXkbjXdZ3VAJ/RMMcDf9v3lPtTrskYLmUxxfn1qKK9/
         007JH32tLtM+rOJBgHrtaIX8+m2n2tHtNlY3j23pK4cU43ZNpzJ0VYItpzjmlJsLonah
         USP7dUXLHERm/Xw6+lE1L4tY9t/L0vAmGtmR7epfsqDxWs574aFQx5s3MIJNRbLEmNwB
         +V9BeuilrFfhrp7rTfd2fwRG4EHB2WSHceMeTxTOhZZkeIhpYFg8V+qGhF6SSRjPoucQ
         yFjDFeE/Y35bqjGIEXiZnOQdIJHBf1LS3ujAUMYzDoWgNAU+iLL9Oq7zxUg4jHXFuL/j
         /weA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=R7YB7UDn;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=yq8K5vFq;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id i3si20589qtj.108.2019.02.03.17.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Feb 2019 17:35:56 -0800 (PST)
Received-SPF: neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) client-ip=66.111.4.25;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@tobin.cc header.s=fm2 header.b=R7YB7UDn;
       dkim=pass header.i=@messagingengine.com header.s=fm1 header.b=yq8K5vFq;
       spf=neutral (google.com: 66.111.4.25 is neither permitted nor denied by best guess record for domain of me@tobin.cc) smtp.mailfrom=me@tobin.cc
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id E21162054D;
	Sun,  3 Feb 2019 20:35:55 -0500 (EST)
Received: from mailfrontend1 ([10.202.2.162])
  by compute5.internal (MEProxy); Sun, 03 Feb 2019 20:35:55 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=tobin.cc; h=date
	:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm2; bh=fosNBr64j7N3LqvNeuUMYV4VjDM
	KlvGUlOdVmegIm5Q=; b=R7YB7UDnaaRDdxzEk+14bbqBt3n5F/yn3CvLI/FfAXV
	6BXdo4VvTfs6YBQqxySevS9eEwuGhYSxp2zc2nieAlrLbLHA+ES9cIkQhkiLxFbE
	iZiOZZL0NtkAx0Ed6z2G3aaOWpf43a7HnoLmmlaLID1kLdcgy4JRykCqJ2VM27zO
	poGTeNX+OZ4UVyHpJiXQtk6zs6+tzbFW8sQMAB/gzufETl219RLFGzI3j/xlLRpC
	JmXunhpvHfoCM8cWbWHN3aSHRfVcgFJ8dUS+CKLKXwRgwVw/Ru3MNdrJxwJSDeOM
	rZShDMqRwSQ9cv2CAd+iEu9bq0EJ3pL9Rh7+j5bSJsw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; bh=fosNBr
	64j7N3LqvNeuUMYV4VjDMKlvGUlOdVmegIm5Q=; b=yq8K5vFq6T9P6ZVVMBw9mb
	0qG4etlLJcgx9e5v1pGYB0dF/0TfBay3rPnA2WGdv9K9LlOAOH/uye6B5VwhR5QC
	DIsrw/YG4n9oFWkoc5KQLaPm80NiaucxuMRQ2nNj1uKlV8I8P5poffQtqWM2TiAu
	TfCSDIG7lq+4w0OWYgWeh6rwaN3nm9Q8V5FLbkeuyuWVRZ4lL7jD8kntbNp2vhl3
	nHCp+drzGmrxUHcEZJebKMdwYwd6zUGSOy85C+6TycYnoRm9oIb3115XMAbja4ZF
	iITAMsyq0xeJ8XlzgZz9sEz4jedtOSwsQF9a1ZcKdXqMVGsH4k1nc4y62VmcVS0Q
	==
X-ME-Sender: <xms:-JZXXMevt7vPb58i2jCgPwz4QIcjYQXqxATx0QWcMpq0Yh3mOep_vA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgedtledrkeefgdefhecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfhuthenuceurghilhhouhhtmecufedt
    tdenucesvcftvggtihhpihgvnhhtshculddquddttddmnegfrhhlucfvnfffucdlfedtmd
    enucfjughrpeffhffvuffkfhggtggujgfofgesthdtredtofervdenucfhrhhomhepfdfv
    ohgsihhnucevrdcujfgrrhguihhnghdfuceomhgvsehtohgsihhnrdgttgeqnecuffhomh
    grihhnpehkvghrnhgvlhdrohhrghenucfkphepuddvuddrgeegrddvvdejrdduheejnecu
    rfgrrhgrmhepmhgrihhlfhhrohhmpehmvgesthhosghinhdrtggtnecuvehluhhsthgvrh
    fuihiivgeptd
X-ME-Proxy: <xmx:-ZZXXCTlSuswCPlYyy8yuJzPwEbwNAbHyl8cTorh29bGuGJcnw0xxA>
    <xmx:-ZZXXOrNOmQxpt7b0XxF-fI_M8EEvIE4MQdg1qGqg4YB938Rh0lb1Q>
    <xmx:-ZZXXLVGqmIrZmaCyCUMQxP2RTEiptO5OalMGG5IpPTEGt-gOX7LUg>
    <xmx:-5ZXXILPRVR2SAoJQQa6cPS6Gzg4ynxIJBMJFGTQ8zRk6luq9ILQHQ>
Received: from localhost (ppp121-44-227-157.bras2.syd2.internode.on.net [121.44.227.157])
	by mail.messagingengine.com (Postfix) with ESMTPA id 8F69FE43B7;
	Sun,  3 Feb 2019 20:35:51 -0500 (EST)
Date: Mon, 4 Feb 2019 12:35:44 +1100
From: "Tobin C. Harding" <me@tobin.cc>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
Message-ID: <20190204013544.GA9555@eros.localdomain>
References: <20190201004242.7659-1-tobin@kernel.org>
 <20190201024310.GC26359@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190201024310.GC26359@bombadil.infradead.org>
X-Mailer: Mutt 1.11.2 (2019-01-07)
User-Agent: Mutt/1.11.2 (2019-01-07)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 31, 2019 at 06:43:10PM -0800, Matthew Wilcox wrote:
> On Fri, Feb 01, 2019 at 11:42:42AM +1100, Tobin C. Harding wrote:
> > Currently when displaying /proc/slabinfo if any cache names are too long
> > then the output columns are not aligned.  We could do something fancy to
> > get the maximum length of any cache name in the system or we could just
> > increase the hardcoded width.  Currently it is 17 characters.  Monitors
> > are wide these days so lets just increase it to 30 characters.
> 
> I had a proposal some time ago to turn the slab name from being kmalloced
> to being an inline 16 bytes (with some fun hacks for cgroups).  I think
> that's a better approach than permitting such long names.  For example,
> ext4_allocation_context could be shortened to ext4_alloc_ctx without
> losing any expressivity.
> 
> Let me know if you can't find that and I'll try to dig it up.

Hi Willy,

I haven't managed to find the patch, I grep'ed LKML using a bunch of
search terms via the google group linux.kernel.  Then I tried a bunch of
different search strings in google prefixed with `site:kernel.org`.  All
to no avail.

I have an idea how to fix it without making life less convenient for
developers *or* for users, I know we don't discuss changes without a
patch so I'll hack it up.

I'm sure your solution contains things I don't understand yet (read: the
cgroups bit) so I'd love to bring your patch back to life but am happy
to work on another solution as well in the name of education.


thanks,
Tobin.


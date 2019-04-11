Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9448BC10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 44CCB2083E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 08:27:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="JigCMARg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 44CCB2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=iki.fi
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDB5B6B000D; Thu, 11 Apr 2019 04:27:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8A5B6B000E; Thu, 11 Apr 2019 04:27:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B797D6B0010; Thu, 11 Apr 2019 04:27:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B4066B000D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:27:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id g7so4408692qkb.7
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 01:27:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8u2aEsZLEcR3+NjWzB2WQbH67+zA4PHcHkWEVgf17q8=;
        b=BWTTZ9yw3usB7T019IRDm2wuVd4x0s6xdSH4aMkxVit+wSySlScfc5FctMGFS4Sowt
         WNznLCk9YArSypzhtg4lKhHuPNwBwiVl2XgHmbwKzGXpxPlZYwpeRRnfLE9u6Iou2CFq
         aNdOhXUiQ0+lXk7ET4QjITgp+KPtzAtE+oODEAYw6WzbUEc7Zt7zV7gxpnX8hMkWRwG6
         fQOa5j8ZbdKgTQEn0L6SI1eOAxbJLWeihRc1Li/q1AuU95PZENMcrMv3Y/T5OMYAdowF
         Fi005tURO0cnqp0zfeZjS4+FcxPTG7zA8kyJ5c377hfK104cjn6XdvFfkniB/dWPwenF
         HxvQ==
X-Gm-Message-State: APjAAAViKFc2d9MxjByzwT5lcnLoIhJ4TAHhgZtoJyoIfoxp7O6X1nJ4
	p97sYaZ/95z4iLOl0/WILPTLZIfDPVtmg3D2K0OqBAH4Q0yep9L0tM/NN7TiqM7HMDI3Ci6hI/o
	faerBexEisI/nAtj7ZmjLt89OUsYvAtmFAbNPu5SUHeIfk/eQVHgNtCc0HNQnayc=
X-Received: by 2002:a05:620a:11:: with SMTP id j17mr38074000qki.111.1554971253356;
        Thu, 11 Apr 2019 01:27:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVnSD+kEK/LFzU1N+nsIrgg4EnllvBnbV0ARDSaCxeNJN3hXVWFB3pEQGIA6iDWV/RXxid
X-Received: by 2002:a05:620a:11:: with SMTP id j17mr38073980qki.111.1554971252796;
        Thu, 11 Apr 2019 01:27:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554971252; cv=none;
        d=google.com; s=arc-20160816;
        b=yjDvHT1+Si9eMEZ5VcsDuZmD5mZk8mDfaO8A1VAHICRmpOW39UbKS4X1G3DK5GNg1s
         08TCdj6rd4PTQBciuqDnGo0cMCQmykKCoVeVCBjO2ppZR3gwIsi3hPE+sqwj92YDVPvk
         8tdpwKFTKzAQHVFr8cEKPXbmF8GFDONozf6n/yVn3PszVguq6hrix9yg6YvTkB2Q4Fmn
         yri2MMGd2ouFTIA3XBlGEJcGFlGvKHPmQ9BOXZ5KOpNBOk3JP4JGQjN9a7lgXDDL4Y25
         d6ZFZab0yKjTSAjcasfbuoGunAXQj9p76DOBVnQ2NUwCLNwhvLu8C5h5EpfHNIZd2ucd
         R5gQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=8u2aEsZLEcR3+NjWzB2WQbH67+zA4PHcHkWEVgf17q8=;
        b=VBfFbBom5nPYREWFC5yZw927iSh6EJBLY+C7BGxN/rZb02V6/dUogRiLDIk56P7jmV
         yFP+iixY+W3SdNXxJs83bsBqv9T5347arxZiEkXbQZdrFF1RzE6q7uupN4LQWw4DsmNC
         FxsvGTVT1N5PLpTkOuWD13siwjJrdilwSZEN5KHDQA1uRsA9Ioj+54RYXZzcsS2s2QKG
         J3eEGoeSRgdZ6Q2FeNvmUYuENYvvog93FqnhmLh0hdOm9lEErbVV/2xSvMhKF/+0vB9N
         mfxDmQ/s20pGWJfX8nXAeb7ZB0VZh4NBcosXHwWtQa+8rEyxaandq1jks3/dE12EVoCS
         jRfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=JigCMARg;
       spf=neutral (google.com: 66.111.4.224 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from new2-smtp.messagingengine.com (new2-smtp.messagingengine.com. [66.111.4.224])
        by mx.google.com with ESMTPS id c11si6742618qko.203.2019.04.11.01.27.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 01:27:32 -0700 (PDT)
Received-SPF: neutral (google.com: 66.111.4.224 is neither permitted nor denied by domain of penberg@iki.fi) client-ip=66.111.4.224;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=JigCMARg;
       spf=neutral (google.com: 66.111.4.224 is neither permitted nor denied by domain of penberg@iki.fi) smtp.mailfrom=penberg@iki.fi;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=iki.fi
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailnew.nyi.internal (Postfix) with ESMTP id 663755A4B;
	Thu, 11 Apr 2019 04:27:32 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute4.internal (MEProxy); Thu, 11 Apr 2019 04:27:32 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-transfer-encoding:content-type
	:date:from:in-reply-to:message-id:mime-version:references
	:subject:to:x-me-proxy:x-me-proxy:x-me-sender:x-me-sender
	:x-sasl-enc; s=fm2; bh=8u2aEsZLEcR3+NjWzB2WQbH67+zA4PHcHkWEVgf17
	q8=; b=JigCMARgrDNIum5VLN/vsLwM+7b/HmaMjhOl1gQgI1DMsfEtQqx1Lp7V+
	I1LKTlANOniVThkARVNXhfzle/8SlP4NfgNpkJTg8HIUvDryMe5NqsIfP9ZPnBpj
	cm1QmSfLlvmamSRIQ/7QJZz9c2WKBAmZllGZvlhijoyOLXwG4O/QleI0bnmAf9A0
	dyZxq7AqyAL/j9MWFghdSCXxSmZI/oYZ8rkzytD1JbwlP5znLwquo9CdX+c+ZrIm
	FKIh6n+Qcvb9+OW9or4cHefL1Gop8IEXaP66p+iBv/6SWUMb4mx+12wNXyutZi1P
	qZO3AK7K/isKWsgBGqfEZn5IdM98Q==
X-ME-Sender: <xms:cvquXPlLS1jKDZyF9S0eQ_ARSvEfJaE7UTphtybQYLmmgUSR3eXa8A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrudelgddtgecutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpefuvfhfhffkffgfgggjtgfgsehtjeertddtfeejnecuhfhrohhmpefrvghkkhgr
    ucfgnhgsvghrghcuoehpvghnsggvrhhgsehikhhirdhfiheqnecukfhppeekledrvdejrd
    effedrudejfeenucfrrghrrghmpehmrghilhhfrhhomhepphgvnhgsvghrghesihhkihdr
    fhhinecuvehluhhsthgvrhfuihiivgeptd
X-ME-Proxy: <xmx:cvquXCamhNVXpsG2lkdemOFWlAxkJKq2ForH_5aE07efjcGoYJK3jw>
    <xmx:cvquXMEySeVlh6qzIBe5XnJoCw6dGLvQ3VvBDKXlDYuPz6GDL22hiQ>
    <xmx:cvquXHLQew1GiXylqBoe1ISWPi81u7HBHR74FEMTlUI8Fdss_PzvJQ>
    <xmx:dPquXBf-aX-K65DfcfNHEHMBQsnTnMeRjjbt4v2zvPC6APqNaf3OqA>
Received: from [192.168.1.104] (89-27-33-173.bb.dnainternet.fi [89.27.33.173])
	by mail.messagingengine.com (Postfix) with ESMTPA id 2B2E01030F;
	Thu, 11 Apr 2019 04:27:28 -0400 (EDT)
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
To: Michal Hocko <mhocko@kernel.org>, "Tobin C. Harding" <me@tobin.cc>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Tobin C. Harding" <tobin@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>,
 Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>,
 Qian Cai <cai@lca.pw>, Linus Torvalds <torvalds@linux-foundation.org>,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Mel Gorman <mgorman@techsingularity.net>
References: <20190410024714.26607-1-tobin@kernel.org>
 <f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
 <20190410081618.GA25494@eros.localdomain>
 <20190411075556.GO10383@dhcp22.suse.cz>
From: Pekka Enberg <penberg@iki.fi>
Message-ID: <262df687-c934-b3e2-1d5f-548e8a8acb74@iki.fi>
Date: Thu, 11 Apr 2019 11:27:26 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190411075556.GO10383@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 4/11/19 10:55 AM, Michal Hocko wrote:
> Please please have it more rigorous then what happened when SLUB was
> forced to become a default

This is the hard part.

Even if you are able to show that SLUB is as fast as SLAB for all the 
benchmarks you run, there's bound to be that one workload where SLUB 
regresses. You will then have people complaining about that (rightly so) 
and you're again stuck with two allocators.

To move forward, I think we should look at possible *pathological* cases 
where we think SLAB might have an advantage. For example, SLUB had much 
more difficulties with remote CPU frees than SLAB. Now I don't know if 
this is the case, but it should be easy to construct a synthetic 
benchmark to measure this.

For example, have a userspace process that does networking, which is 
often memory allocation intensive, so that we know that SKBs traverse 
between CPUs. You can do this by making sure that the NIC queues are 
mapped to CPU N (so that network softirqs have to run on that CPU) but 
the process is pinned to CPU M.

It's, of course, worth thinking about other pathological cases too. 
Workloads that cause large allocations is one. Workloads that cause lots 
of slab cache shrinking is another.

- Pekka


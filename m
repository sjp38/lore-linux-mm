Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 041F4C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90DE62075C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 14:52:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mtRExl5r"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90DE62075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 031A26B0003; Tue, 26 Mar 2019 10:52:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFD9A6B0006; Tue, 26 Mar 2019 10:52:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DEDDC6B0007; Tue, 26 Mar 2019 10:52:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D1286B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 10:52:03 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id k1so3083914ljc.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 07:52:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=XI8nG9Dzmt5ShimcJLgUrFfOlr1UjZ/4vfezN58z7mI=;
        b=erd/c+TQ7oTTtDkYeQRWPoCSpC0k4G4JteYzAJWZvmX5wUtTSLaw6i2+VtbsN44jSX
         JD8LF+S5Ys9QL3M+Je3zIcJkA37M0yvSGhAOLDqfSME+sEdnGEIt2deTmdMzbzFbrNiP
         1AxEBnzoDhsKDYTGUAeBUad+6c3OZCHG94pxQAW8SZnPzSmgWaK1Kcfz0IZ+SBpyIwN7
         yAYM+z2mKwOZ/TTu0E/qp8ii/kierCMzZOjmsh9z30bKAfb5N/KWt4irAtHGCYV+VZYn
         iGW1k1rl9Z039XpFqTFbVBHC/IlPzKmTET1RJeHqVW5dFhjOGxAjky9yXi2dPBnmlS+0
         sWLg==
X-Gm-Message-State: APjAAAUaorS75ipspo6LeUSWoUXKzs7Jevu/1kgepHJC0OeWWY1svlrm
	1Kg8oo8+EvhMwVBpeLtyXdcRsvcmG2cyZvkvrjgBhO4aPGf+jSo10Qv6Vqzr4QPX2fgTY9k2Grl
	xSrPc745k4DJfrLdkAGRIP8Ks+ItArv76BAWmQVSc75F8e43IjEKEv5n0op8nSCrd7g==
X-Received: by 2002:ac2:5638:: with SMTP id b24mr1795578lff.18.1553611922895;
        Tue, 26 Mar 2019 07:52:02 -0700 (PDT)
X-Received: by 2002:ac2:5638:: with SMTP id b24mr1795529lff.18.1553611921967;
        Tue, 26 Mar 2019 07:52:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553611921; cv=none;
        d=google.com; s=arc-20160816;
        b=CVjQjuam70b0bCpgvZL8B75EX5BsHDHALNSq4lQANfzO4+0cOcipLlx9ojngSFmtYG
         NKEc+K5Sg/K8k/cSCjbDcKPmIkAYs+i4WuwKSjadNC4TTuv9GZKPLHvubSIDRvtVm5Ty
         dazx4nZPyo1ZBYVM8DWs4W+IoafnNYU8njDSYVky7Vmit0XUEBeuF40j25eK7U9aAndc
         RJAlK9YVK3TRWkR6acTWlqCXGmIymQfnHfjuALbxxYbbfBpUi/iCdjYC1HH/7ULwhnbm
         kBVGiqJEXYEzqJprH3n+PT8Vl0w2D4Vss41z4Te5yxQUHhEYoeHw1QZNGPrjOPTICCss
         2uBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=XI8nG9Dzmt5ShimcJLgUrFfOlr1UjZ/4vfezN58z7mI=;
        b=QfsxAO4YS6pSrLePSNXMSMojOcdQzCfXGt1qCAESYollRr5rc+wlebdQ3eUwdSBsFC
         Uc2gSLdYGde3gAZDojy4NCu8Sxy+C8/+qudNm+weQLxb6p0rNX2gOBPfit+pHKbY9R9D
         cDJF8aqsrLj5i1h7wvedp/v9UrrcFLGn93HvDTSBnwAc6Zpq8hBicDh1Jrj2UbsdwmZU
         drAVMXf/0PpnseBh5hLqUiCikZi16OE0Zygt7HG0n21FUmZpOuD4TuQOm92M0HeRJNUz
         1NBKvS6YXtzjNTlLtilCgdKuWbF96y3VkOY+PlNmLt1RZs3fW1tW737T+eP4fe8q2Z+1
         L9tA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mtRExl5r;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10sor6505354ljd.5.2019.03.26.07.52.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Mar 2019 07:52:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=mtRExl5r;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=XI8nG9Dzmt5ShimcJLgUrFfOlr1UjZ/4vfezN58z7mI=;
        b=mtRExl5rQvp5nbXGCI/zHz/hSZxZNfiZyNqO8FojEpmtvcCqNgzb3mRjnpamZQpWW1
         K+OA4pLUbXctnOw0xvAiKD02hDCUZfrUw71JcmXKz/mqRJCXsvCpSj/+3/KGT3+5+8eh
         r2sLoGsjsor9eNEnoOIzMKNlos+7JfVp57yi62KnmvFjoB/uNd9J/1yl7Q3y1rjPHEgO
         TuK1VMYuXbA09G7aFW3F0IZPrMpQru4ZFRCakwwB6slytwAsXVG9WwFVEVp8Y9F2Gb0k
         Yzf0P9fLan8AXDY5nSAb11qnf+GkkzITTpGXt+nGctYowVFX3P3Bkeq9oD3wYv3qymgD
         7Uow==
X-Google-Smtp-Source: APXvYqzTtQP+oFFD8jGFvpEJTrQjS1fwAFTra0tU4Xfa6gY3j2lgi5Z8Wwn4YaJfUT5HfAbn7DrrrQ==
X-Received: by 2002:a2e:9655:: with SMTP id z21mr16910027ljh.60.1553611921190;
        Tue, 26 Mar 2019 07:52:01 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id y1sm4118474ljj.13.2019.03.26.07.51.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 07:52:00 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 26 Mar 2019 15:51:53 +0100
To: Uladzislau Rezki <urezki@gmail.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 1/1] mm/vmap: keep track of free blocks for vmap
 allocation
Message-ID: <20190326145153.r7y3llwtvqsg4r2s@pc636>
References: <20190321190327.11813-1-urezki@gmail.com>
 <20190321190327.11813-2-urezki@gmail.com>
 <20190322215413.GA15943@tower.DHCP.thefacebook.com>
 <20190325172010.q343626klaozjtg4@pc636>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190325172010.q343626klaozjtg4@pc636>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Roman.

> > 
> > So, does it mean that this function always returns two following elements?
> > Can't it return a single element using the return statement instead?
> > The second one can be calculated as ->next?
> > 
> Yes, they follow each other and if you return "prev" for example you can easily
> refer to next. But you will need to access "next" anyway. I would rather keep
> implementation, because it strictly clear what it return when you look at this
> function.
> 
> But if there are some objections and we can simplify, let's discuss :)
> 
> > > +		}
> > > +	} else {
> > > +		/*
> > > +		 * The red-black tree where we try to find VA neighbors
> > > +		 * before merging or inserting is empty, i.e. it means
> > > +		 * there is no free vmap space. Normally it does not
> > > +		 * happen but we handle this case anyway.
> > > +		 */
> > > +		*prev = *next = &free_vmap_area_list;
> > 
> > And for example, return NULL in this case.
> > 
> Then we will need to check in the __merge_or_add_vmap_area() that
> next/prev are not NULL and not head. But i do not like current implementation
> as well, since it is hardcoded to specific list head.
> 
Like you said, it is more clever to return only one element, for example next.
After that just simply access to the previous one. If nothing is found return
NULL.

static inline struct list_head *
__get_va_next_sibling(struct rb_node *parent, struct rb_node **link)
{
	struct list_head *list;

	if (likely(parent)) {
		list = &rb_entry(parent, struct vmap_area, rb_node)->list;
		return (&parent->rb_right == link ? list->next:list);
	}

	/*
	 * The red-black tree where we try to find VA neighbors
	 * before merging or inserting is empty, i.e. it means
	 * there is no free vmap space. Normally it does not
	 * happen but we handle this case anyway.
	 */
	return NULL;
}
...
static inline void
__merge_or_add_vmap_area(struct vmap_area *va,
	struct rb_root *root, struct list_head *head)
{
...
	/*
	 * Get next node of VA to check if merging can be done.
	 */
	next = __get_va_next_sibling(parent, link);
	if (unlikely(next == NULL))
		goto insert;
...
}

Agree with your point and comment.

Thanks!

--
Vlad Rezki


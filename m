Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59F77C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:53:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 06E76206BA
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 15:53:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jaH0QyHe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 06E76206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A67C6B000A; Thu,  4 Apr 2019 11:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 955BA6B000C; Thu,  4 Apr 2019 11:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 844736B000D; Thu,  4 Apr 2019 11:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18A206B000A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 11:53:19 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id x18so321597lfe.19
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 08:53:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=69s05neAi83p1BcVREyc1LoY0XUeiOlTcpfAjyTNwYY=;
        b=FVPo/KHrjkWJwZ+rXJDacJTh2GEAsQ8iJJ2cYGkG7BGFaiC4LNLsgB5T7gLHW9Osfc
         fbMX5RpxH4TS+FsZ/nWelpa3EuP7O/JgVxjBHXsja4A9dlnJmwsgRKtVdwn8eNnw5r7G
         yqHRt6Lc8c8aHbmOCORVROZO5AMgBnr8dGkZuPBO4khlRvGwv5aae3XxdrD10eCFeqg/
         69FQcCdJmeZMWOMuqmRGGcWDRG70fdiWPsFsYGPxmI3iTejkqVmetRg/Q/PXC96wDbXK
         UBOPDfAToFzBDf1z8r5Dxwx7vmbWalvym5jCTGYinhPBfayFZJ1RUvnu3RL1PQ4sczbi
         IHVA==
X-Gm-Message-State: APjAAAX27v1kl19TdpjfhMMc1pWXT9YZbLwKLWXxJj4+D04VcysYhKkW
	Ym9EbR4KE69y1JvPgkJcqpDZJzw9PjE5BnpyC8RqPX0AwgR3tB3m9nErXXfGPLEDk181lEtK8Cl
	OsX1SFUxNiIwRRJ9e7/NgUsFm86Y/Q1nPQpoeyhfEX5o0mmi809kGsTWJdl8tTL5+TQ==
X-Received: by 2002:a2e:9151:: with SMTP id q17mr3958730ljg.87.1554393198541;
        Thu, 04 Apr 2019 08:53:18 -0700 (PDT)
X-Received: by 2002:a2e:9151:: with SMTP id q17mr3958686ljg.87.1554393197673;
        Thu, 04 Apr 2019 08:53:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554393197; cv=none;
        d=google.com; s=arc-20160816;
        b=jCQKbb7R3f+EBBnWxBThLiz0hJF1LJR7t3T+cHVsdT83pyCvYcqDReO10gwjI4rFoF
         GqB3eYOiK5jvzG/Q8s+iHV3fSEI07d5l0JqjTXxcBfbUFJYjvT9FaGph849ub2g9zCRD
         VUfO+4hqecjqHV4rfwvtUa8wZgcQ+I7dtTittUJ5G7dazB6tf5yV3fO1SFQ+4fFjdw8C
         sysYDreeG4VQgxvcbO0fz0oussNs6LAUUM4lTRkFl05JOd0su9kvE9WkXIFlA8YLIYfy
         84860LOHYHxB/KRtI7WryNyMwzqYsCZ9FOwDrRa+uUXPsEMhmVnAt3L9KbwfHccH1994
         CElg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=69s05neAi83p1BcVREyc1LoY0XUeiOlTcpfAjyTNwYY=;
        b=eEHoUaZx2+Do3Sjz9VsjXMc+PPHJXNt8RpLMCI3zMGsHmO1zK+S9ut/09JKy+LATD1
         nN9XkLxiXM/PsyoPszvwNdrQLCzIVsdCkeudGe02jrlaF2wCOKkp/SKTQ6kJgzADt21X
         K7OEfSVE/AjlFIQO5xUn7CjE5vE4zspmPa/l6mwDuU6MfOPOGuuwrRJv4yG69BvgnVDR
         8Qiqji03rJy7hxFHmT05P2EoVQOF/iI7boV1oap1Z6TI9cC79Ow8gSjdkh74p/kX00zE
         4A31swz4tefvvbYW+AVtXRwdG+5wsQjJ8Wjc45iJETFVI3b60zw/lGp+7awz01W6FhUh
         I/pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jaH0QyHe;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x17sor12689266lji.20.2019.04.04.08.53.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 08:53:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=jaH0QyHe;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=69s05neAi83p1BcVREyc1LoY0XUeiOlTcpfAjyTNwYY=;
        b=jaH0QyHeb+dHGmubQzhMukaX7N16Vxg6TLoBCbEwjeuBdxAScZXs48BE+NaYkURPAW
         WbsWb00NyxZvd1ZGyxWE6xPlKD+LHFB7+53cGtdRt5Tl1nJ9mYlWDSen+YgJwSbZJGjs
         lJQDEysz4/HvKafsLo+U2/B5insAknqJviVUz0ATypYdpWsKydZ7Z9/TD4rrSJglCfcW
         eq4HMzoz2g7sHy+UJuzVlCpeUHeEMaadA/3IXCb4IgP/maO074fOWSQwQEMHamm3g9UD
         Eylsw3nXTSTRi5/oXqmxARq/tNA8U/G2+XgClXlJ7gI2BvAcM1G6QoAE/ES3Wcjth/I7
         1lkQ==
X-Google-Smtp-Source: APXvYqzj0uwo/mfji4kDTEIceD/EGvOp0fUilEJhJczaWSYf+ko+2/oKhY6O+VuCheQOVW9pumjXAg==
X-Received: by 2002:a2e:292:: with SMTP id y18mr3779169lje.52.1554393197268;
        Thu, 04 Apr 2019 08:53:17 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id x2sm3702757lfg.59.2019.04.04.08.53.15
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 04 Apr 2019 08:53:16 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Thu, 4 Apr 2019 17:53:09 +0200
To: Roman Gushchin <guro@fb.com>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
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
Subject: Re: [RESEND PATCH 2/3] mm/vmap: add DEBUG_AUGMENT_PROPAGATE_CHECK
 macro
Message-ID: <20190404155309.udxvjorbq7shug4v@pc636>
References: <20190402162531.10888-1-urezki@gmail.com>
 <20190402162531.10888-3-urezki@gmail.com>
 <20190403211540.GJ6778@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190403211540.GJ6778@tower.DHCP.thefacebook.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > +#if DEBUG_AUGMENT_PROPAGATE_CHECK
> > +static void
> > +augment_tree_propagate_do_check(struct rb_node *n)
> > +{
> > +	struct vmap_area *va;
> > +	struct rb_node *node;
> > +	unsigned long size;
> > +	bool found = false;
> > +
> > +	if (n == NULL)
> > +		return;
> > +
> > +	va = rb_entry(n, struct vmap_area, rb_node);
> > +	size = va->subtree_max_size;
> > +	node = n;
> > +
> > +	while (node) {
> > +		va = rb_entry(node, struct vmap_area, rb_node);
> > +
> > +		if (get_subtree_max_size(node->rb_left) == size) {
> > +			node = node->rb_left;
> > +		} else {
> > +			if (__va_size(va) == size) {
> > +				found = true;
> > +				break;
> > +			}
> > +
> > +			node = node->rb_right;
> > +		}
> > +	}
> > +
> > +	if (!found) {
> > +		va = rb_entry(n, struct vmap_area, rb_node);
> > +		pr_emerg("tree is corrupted: %lu, %lu\n",
> > +			__va_size(va), va->subtree_max_size);
> > +	}
> > +
> > +	augment_tree_propagate_do_check(n->rb_left);
> > +	augment_tree_propagate_do_check(n->rb_right);
> > +}
> > +
> > +static void augment_tree_propagate_from_check(void)
> 
> Why do you need this intermediate function?
> 
> Other than that looks good to me, please free to use
> Reviewed-by: Roman Gushchin <guro@fb.com>
> 
Will remove, we do not need that extra wrapper.

--
Vlad Rezki


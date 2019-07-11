Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C60C5C742A2
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 21:34:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89C11208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 21:34:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89C11208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A2618E00FC; Thu, 11 Jul 2019 17:34:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 051E58E00DB; Thu, 11 Jul 2019 17:34:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5C0B8E00FC; Thu, 11 Jul 2019 17:34:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3C88E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 17:34:17 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id z24so2067159wmi.9
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 14:34:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=4DbAui3JRthBbn+rH3ZbT6KQozOdSL1BfgrMWL8KxQU=;
        b=D9D0sZQhspDGMYu7+UJEl2uui2SceAGhk5meAbBVMXy96gfvk1WppEG1a26Wz9iGHd
         2Ar+3pqyH0tQdAkM7YfjKEBIBSYjCfPAvdzP30tmX8nbfKj1Oclq6AOd8QuQD/9YvmYv
         2uR7lGI1HUNa8rgXMxTvy1EBlAz7dfZI1DQxp0+AjQVReoSZK9s8GoaIzLmkFM0mPA4l
         iVHQnXCMGe+O9TM+AzLpxl5r1I0+ikOZSzZCGHYVlzd0RqfzwMB4+hXgKOs6h8ZXa6NR
         SgShSdj+K8TxxAJLUeStxUQZOp/BvzMBd+UyeXnE0C1kcOIaVHWbgWoUnFaXrrH4SMqk
         vGag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVR8EJV7VkPhl5Eh8oW3aVxBgJYq1o527b9sP/UzHTuHKwsR5Ar
	N1yvAWDHJ4Xyf0mU7ThNlwUOrrPN4aIgZWyEwAE57HPY3iaNkHcHf08O3CP4kq38RowA5DPY8u6
	F5r/UhyDyWsUqEOOM3AMQHAYApSoqy+jnxMqKLIulTUxk9fVvoJeOx6TeqXl/c3CNcQ==
X-Received: by 2002:a5d:6a84:: with SMTP id s4mr6918552wru.125.1562880857105;
        Thu, 11 Jul 2019 14:34:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx6QRX5qTgAOJOE2Wm1IuKq/9gzNcwpUqcnedBBB22O+w7dODu779b+J+0b1loUX5UPyZr8
X-Received: by 2002:a5d:6a84:: with SMTP id s4mr6918516wru.125.1562880856338;
        Thu, 11 Jul 2019 14:34:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562880856; cv=none;
        d=google.com; s=arc-20160816;
        b=CH6otFruRuWs21aPPS3Ah7RIrqleO1/uGkwt4N9DIIK0/0cjau3uz2Rn3RxuTZqnUJ
         DD4U4mH7GQdwPOkALqfRFz+xaYdAkHkhH1APvqMhaV9Xk7qGdt3FAK3CHwLZSKmeJYtk
         iHAbBjet/+jB49DXmVIEk/2dxHjoLJ9m5mVVugTN6a16/HmN905jlK0KmbaGR7kPUh+G
         pLV9qjqQCUHmn+/1pCQTenNpvjiglmAus7UcqthZi+4SfqxhWFyFFlHwCIqn3UB+sD1J
         4YoklfnIolgTVaRzBF79H8A5cS/aFzIcAJ0aebvGzdUyXbcTB8A6LjK5i+JbFC+pDqsb
         J+bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=4DbAui3JRthBbn+rH3ZbT6KQozOdSL1BfgrMWL8KxQU=;
        b=h6i5Tt3gJWGa0g5mM+Fjrw15hg/7ZZHhW0xLwCSBFuwJxytIJoE77K78KbLCm5P+Kc
         ycnyp/onC1503eyIt2DmUMXXpNvUp0+pYmbZl7f9m/6OZHeAEj1k1CRpGzzLyW8KZgh7
         vY1of+X0LZGl+D9CRnZpjXwNQUD03ShHl6G8nLt+PMst88mhcYsNX6X7PfgO/VVmiVZI
         gSd5aQT7oVhS7HVKF2f+fV/TBANqUmNmfcW/oyNtr1fcsBGa5aie23EYRpviUizz+9W9
         q0jYHYI3qbijwlUFFTwE5KByXcW6PJIDQ5rtZ4OsAc8IdDDGKDyKf/womwLCj+S7rz2K
         Z6gQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id j3si8283804wrs.215.2019.07.11.14.34.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jul 2019 14:34:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hlghS-000289-8D; Thu, 11 Jul 2019 23:33:58 +0200
Date: Thu, 11 Jul 2019 23:33:50 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Alexandre Chartre <alexandre.chartre@oracle.com>
cc: pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, 
    hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org, 
    peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, konrad.wilk@oracle.com, 
    jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com, 
    graf@amazon.de, rppt@linux.vnet.ibm.com
Subject: Re: [RFC v2 01/26] mm/x86: Introduce kernel address space
 isolation
In-Reply-To: <1562855138-19507-2-git-send-email-alexandre.chartre@oracle.com>
Message-ID: <alpine.DEB.2.21.1907112321570.1782@nanos.tec.linutronix.de>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com> <1562855138-19507-2-git-send-email-alexandre.chartre@oracle.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jul 2019, Alexandre Chartre wrote:
> +/*
> + * When isolation is active, the address space doesn't necessarily map
> + * the percpu offset value (this_cpu_off) which is used to get pointers
> + * to percpu variables. So functions which can be invoked while isolation
> + * is active shouldn't be getting pointers to percpu variables (i.e. with
> + * get_cpu_var() or this_cpu_ptr()). Instead percpu variable should be
> + * directly read or written to (i.e. with this_cpu_read() or
> + * this_cpu_write()).
> + */
> +
> +int asi_enter(struct asi *asi)
> +{
> +	enum asi_session_state state;
> +	struct asi *current_asi;
> +	struct asi_session *asi_session;
> +
> +	state = this_cpu_read(cpu_asi_session.state);
> +	/*
> +	 * We can re-enter isolation, but only with the same ASI (we don't
> +	 * support nesting isolation). Also, if isolation is still active,
> +	 * then we should be re-entering with the same task.
> +	 */
> +	if (state == ASI_SESSION_STATE_ACTIVE) {
> +		current_asi = this_cpu_read(cpu_asi_session.asi);
> +		if (current_asi != asi) {
> +			WARN_ON(1);
> +			return -EBUSY;
> +		}
> +		WARN_ON(this_cpu_read(cpu_asi_session.task) != current);
> +		return 0;
> +	}
> +
> +	/* isolation is not active so we can safely access the percpu pointer */
> +	asi_session = &get_cpu_var(cpu_asi_session);

get_cpu_var()?? Where is the matching put_cpu_var() ? get_cpu_var()
contains a preempt_disable ...

What's wrong with a simple this_cpu_ptr() here?

> +void asi_exit(struct asi *asi)
> +{
> +	struct asi_session *asi_session;
> +	enum asi_session_state asi_state;
> +	unsigned long original_cr3;
> +
> +	asi_state = this_cpu_read(cpu_asi_session.state);
> +	if (asi_state == ASI_SESSION_STATE_INACTIVE)
> +		return;
> +
> +	/* TODO: Kick sibling hyperthread before switching to kernel cr3 */
> +	original_cr3 = this_cpu_read(cpu_asi_session.original_cr3);
> +	if (original_cr3)

Why would this be 0 if the session is active?

> +		write_cr3(original_cr3);
> +
> +	/* page-table was switched, we can now access the percpu pointer */
> +	asi_session = &get_cpu_var(cpu_asi_session);

See above.

> +	WARN_ON(asi_session->task != current);
> +	asi_session->state = ASI_SESSION_STATE_INACTIVE;
> +	asi_session->asi = NULL;
> +	asi_session->task = NULL;
> +	asi_session->original_cr3 = 0;
> +}

Thanks,

	tglx


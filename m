Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E744BC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:39:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8BED4218D3
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 07:39:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8BED4218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05AAF6B0007; Fri, 22 Mar 2019 03:39:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0073D6B0008; Fri, 22 Mar 2019 03:39:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E12BA6B000A; Fri, 22 Mar 2019 03:39:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC1946B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:39:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e55so577592edd.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 00:39:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CDeLsfNgXBd16ExyfevyAjPLEfCfTYZnSi6cKjvocUM=;
        b=RKcBnxbA3GVvcI5L5dvrtSxDU72yDh/OXLfw1gCdW605di/M/vOKEOvjNPleMK4TCo
         J0bnN+jAJGvvinoqbGUQ0MFT1Ve52XMDUGApRrvK3u6/oIRHDTi0ewqh7q4HA89o573a
         LLSnfYiOhIQkByYVNO2Wx7z1YHZdNbjMlyiOMngWu1vDHjI0VC3FX8Qz+xX00Sevl7Ld
         XSQCsAyKX72E95UkdcKnEkK2ea6hdwT0tdI3fOBsNKvLuOX2kR5sWqwNqbUctTEmtPTi
         EC+slbp42vrzFS1xKODfhVp1zgXr4MW0VEFzMeMeMg62fX4gH2quz5SbGL+TgjlxVaGd
         qj0w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAW/DwthYD7t6A2pUhieaMXpbxdoFH/iihiUA/wNpYIemkWW5ETE
	M2urKquKFMIbbujd3cOz7ZUUb8jJNc42PD0RBD4UoqHVm/rd1at8WWxLOLxoD3AbhlxwzIdiI96
	p2u4J7G28QOn9AEb7H3HZpBX9IF7F/tLsgqrt3o0HQAYL8Br/4tzM8C+DBRHazW+Zmg==
X-Received: by 2002:a50:aa0f:: with SMTP id o15mr5317850edc.129.1553240348232;
        Fri, 22 Mar 2019 00:39:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLpy4Ckkbwrfw0QWK9Ak/bw/UiE72I9C3H/6a8+XnG9CUBfXzEIz7vuAAEGy7lmZZOMk8u
X-Received: by 2002:a50:aa0f:: with SMTP id o15mr5317813edc.129.1553240347353;
        Fri, 22 Mar 2019 00:39:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553240347; cv=none;
        d=google.com; s=arc-20160816;
        b=fK131lgpmIEwC50Q9dPjGSKjknocnAhWZtVFfFgt/9VsYD5Wo7bu3gYLOKB7twTXm+
         nptGyCLUcnwqsIEaUdJoqF7r+k4HBXsZW/MDdnes8DoB6t+uApvjC8HlwTgImLXAQtJG
         9fyEcbH5aY614XRByw0448x45TapIOxBRnlUM+tXkuC8urHzpNJKLtF8M6ayv93VPso6
         EoMl2Lt6tv0WbmOss6082PkQXqVZhayeVb7qLPwS3kwfjmR9ZjZgasb6qNOHtynPp8N+
         lOQQzBQplOizOT2BNz3/j3Kit4POx4VLmsFf0aUKTew2ngEJ6K8Wr9E9cph/VevMrqFs
         FBDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CDeLsfNgXBd16ExyfevyAjPLEfCfTYZnSi6cKjvocUM=;
        b=Gx5GLF5pljejwkW0JuVZKSAwEw4DLa0cQ8USdTJULDdSpT0ogjoSZEbyGerbaw/1ri
         WGgYsWDUILaZk0gM5bnoZ7RvDXN+PHQCrO4AqjStJ0iuhfZolK2bUVqzCBgWEYAb3Xuz
         0TE+qBALB5I13qMGt0+D9UYJ6j0xuvP7QALWXqI+46YrT3qjqXVn4G+Rplq6LWeL//NO
         FdtlIyMvfy3J6MYS/NkXc14aub8dg9wLYnU0oreAQNMJFJIb+iMmuA06bhFYzWhMllz/
         +hjLzEvzT61WfqmjUH59WS0Dv9k0uZqxNmBaH+kYnh+5KviQU+dNJwrZg3qFeQ/GOL3Y
         LMEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id i5si3126293edi.334.2019.03.22.00.39.07
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 00:39:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 5E73C4668; Fri, 22 Mar 2019 08:39:06 +0100 (CET)
Date: Fri, 22 Mar 2019 08:39:06 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Cc: linux-mm@kvack.org
Subject: Re: kernel BUG at include/linux/mm.h:1020!
Message-ID: <20190322073902.agfaoha233vi5dhu@d104.suse.de>
References: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CABXGCsM-SgUCAKA3=WpL7oWZ0Xq8A1Wf-Eh6MO0seee+TviDWQ@mail.gmail.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 10:55:27PM +0500, Mikhail Gavrilov wrote:
> Hi folks.
> I am observed kernel panic after updated to git commit 610cd4eadec4.
> I am did not make git bisect because this crashes occurs spontaneously
> and I not have exactly instruction how reproduce it.
> 
> Hope backtrace below could help understand how fix it:

do you happen to have your config at hand?
Could you share it please?

-- 
Oscar Salvador
SUSE L3


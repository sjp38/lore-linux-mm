Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1A71C7618F
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:43:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B62B22184E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 16:43:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="Yi1h9o2C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B62B22184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55C708E0006; Thu, 18 Jul 2019 12:43:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 50D148E0005; Thu, 18 Jul 2019 12:43:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D50A8E0006; Thu, 18 Jul 2019 12:43:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E77B08E0005
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 12:43:45 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so20350685eda.3
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 09:43:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=+W9Fu950QMsufBfCCPx+AFaKU8cPICx7xAobprqzZjM=;
        b=b6LLRneDTY/eDIfLfN89Pa2j1UPG1hV1607s9fUim/QAgkiJUOa4pBgWaWE/Ybtdrk
         BQSRP7NWnFOw1sSPdfvzhgWlPlPBsMt7EogE0NFv7gv6QHne3Gua3WCUaA+7jgLGtq6J
         hcr6JT7wwkcHLTry7U6pIbA5rYlzkwzvYhQJ8ESWFv35MI4Cx9AIwu/Zsgxq9wjIJCyo
         I/PrCDOT58t/DBUmMWOlZa1VdrqUSUxKpsXezok7UY5a8f9RToFI0ZbPJBJzFr+Uwr7Z
         uvCbZUQeKS1oUwza6CMYRdKiD6gAYliO1IE6BtgWkao7tLJ4TKTgh4mD96KoeM8SRjxR
         VsHQ==
X-Gm-Message-State: APjAAAWmNrRY8SKRceUiqdyHR7IF2Ql6nLa9D1M4LY+wuWcOE84PeN7L
	HHBaEs5NFXpQms+cVh9AHOSD4P4TJVSyItb+wZuwvXpOjsRX1smfNMmvdXHi+GpFheFWCKwHL1l
	OSrgDWxsI4OhkyMXDAmGpmXozNU0QN5lr9daPBrUo6mgOyRmr6UUuCpQ1ITmbTwgH6Q==
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr37105677ejb.68.1563468225518;
        Thu, 18 Jul 2019 09:43:45 -0700 (PDT)
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr37105600ejb.68.1563468224707;
        Thu, 18 Jul 2019 09:43:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563468224; cv=none;
        d=google.com; s=arc-20160816;
        b=C7qgYw6OCx4oQ4dbSsjWDu9KMGzkRzviiErMeiG0Hdt3FYV/NDA9zRbbmIPjXwbbM5
         M9Yk0dbeACB2rSDNzE833G+N5KodhNrYWnK3Foe4pWmxdHH/b57MNq+AGZTYNqSJCzdE
         BN7jX/93lsGZO9zEbTfGOJCjNbmT4HqFHdBO+5EEqhZhkT/S6wZBs5r7ur/ThBWUM+he
         6In3tb/0JPOTUeYRAFblo1X46xLJ4IKgAjI7cMloe6SnvAJdMu8dA8ExEU5p9Fro6dkv
         lgtcmloUfGxQEfmReiKgdTys9yDJx9UqY8JQ7PV8Ec3YuUVQuguf6n1ohp5jANRYzrAa
         dqSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=+W9Fu950QMsufBfCCPx+AFaKU8cPICx7xAobprqzZjM=;
        b=KTInn4b8oznpLYHNaUBbBA2Cr5qxznzlE4BjDDQkJd8DqB/MfbTDnLoePnLCU84xWx
         OyUpbkCtb+/ZPTyPyLmqKwoaUswKnwNby165e/MtDjCPDfA8gTVUTV1+vIHFYIf9BXvC
         Aw2Ph/ft2DAznq9MHCQTGvW2rf7o6AxxqZFqk1V8omDIoT0zWJT69m9aIbIE4c2JKKCE
         N7bVPzXC6zDPiJlPjyOfBN8EI78IKQw9fZoxDnK6qFrIybsVYYF5fscN8rCC4nDcBFLM
         DElBi1uqEdWSS8+YIMklVpQYIqMffCl8IOOwLHWbZb0Ujs6feog1E6MUmh+HK/XzR1p3
         C2MA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Yi1h9o2C;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w6sor21888897edc.24.2019.07.18.09.43.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 09:43:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=Yi1h9o2C;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=+W9Fu950QMsufBfCCPx+AFaKU8cPICx7xAobprqzZjM=;
        b=Yi1h9o2CQwbo6Qwnob3MkuqbT3GZvCeRMRmamE2v3Oszki45i8Qs9f/kn68w0M2+LQ
         Ff3szsQU67WdJ6ROZ8QobqIZAfnu5yM69u/ZsjYEguU7FSP3tT7h10tU7QCZmVv3VQWz
         3P9jA++wmEe1qRl4MmW6cB+kCHDIJVOm6KXYcujhMuT6knBHqhKSlNmGYJrFPQL06KRy
         T1P/te4/Q9JeLCfOxj6whZsaMQg9uK+eIFk1VXf9AF4mvFOoq/2gJarF0gL1FrBxHs8+
         gh0+Uec+7Heqi/fpINwOgeIWnXXsWOPhBE1CCM0kVhAYq9EF7UlRqhDeUelARzKrEG9L
         1TWg==
X-Google-Smtp-Source: APXvYqxnrB4IiF1XWQJdXPRciWeUOMIOt0s4We1X1OrTsNZMGgvS6iWNLx4UmmepwkQUKKhdElmEUt7TKDRGSjXGvZQ=
X-Received: by 2002:aa7:c49a:: with SMTP id m26mr42805347edq.0.1563468224397;
 Thu, 18 Jul 2019 09:43:44 -0700 (PDT)
MIME-Version: 1.0
References: <20190718024133.3873-1-leonardo@linux.ibm.com> <1563430353.3077.1.camel@suse.de>
 <0e67afe465cbbdf6ec9b122f596910cae77bc734.camel@linux.ibm.com>
 <20190718155704.GD30461@dhcp22.suse.cz> <CA+CK2bBU72owYSXH10LTU8NttvCASPNTNOqFfzA3XweXR3gOTw@mail.gmail.com>
 <20190718164043.GE30461@dhcp22.suse.cz>
In-Reply-To: <20190718164043.GE30461@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 18 Jul 2019 12:43:33 -0400
Message-ID: <CA+CK2bDG8xNAgn++8uTOP9OsuEzynm=-Gkb+oUj9DKB8sEudiA@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm/memory_hotplug: Adds option to hot-add memory in ZONE_MOVABLE
To: Michal Hocko <mhocko@kernel.org>
Cc: Leonardo Bras <leonardo@linux.ibm.com>, Oscar Salvador <osalvador@suse.de>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Pasha Tatashin <Pavel.Tatashin@microsoft.com>, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> > Just trying to understand, if kernel parameters is the preferable
> > method, why do we even have
> >
> > MEMORY_HOTPLUG_DEFAULT_ONLINE
>
> I have some opinion on this one TBH. I have even tried to remove it. The
> config option has been added to workaround hotplug issues for some
> memory balloning usecases where it was believed that the memory consumed
> for the memory hotadd (struct pages) could get machine to OOM before
> userspace manages to online it. So I would be more than happy to remove
> it but there were some objections in the past. Maybe the work by Oscar
> to allocate memmaps from the hotplugged memory can finally put an end to
> this gross hack.

Makes sense, thank you for the background info.

Pasha


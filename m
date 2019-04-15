Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 891C8C10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 21:21:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 506DD2087C
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 21:21:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 506DD2087C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E028E6B0003; Mon, 15 Apr 2019 17:21:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB2BD6B0006; Mon, 15 Apr 2019 17:21:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA1F06B0007; Mon, 15 Apr 2019 17:21:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6996B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 17:21:00 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id y7so16879641wrq.4
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 14:21:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=Kma0HeNKyiBVfrxk4GuJGuQWMIqSyQzZCi/jszJ9/jA=;
        b=QsCZ3tYxZUqSX2rhPUDBLLxSqpqis55WuTR31SR87Qih234d+Gy1+YNTCOXOwofvQo
         BjaWxFUpNEkfzGUnSfyedroifNInsg7hDC8H0IgyZmHzK86nSsiuTssw7lcpjnx+K60b
         Z0bdusBs4EqO+VJVyni+/VhxSfH24VEKHFbAHxKBfI5tukRgecpkzBh3moCr/C2roes1
         0LYxnWy47KWBqKnUFFXAaDTLokqFeG/b9AbsgZzFZLG/GrMii58pLk3zrH6nM9smM5Fh
         r3BUbGsxQ/3plLBViwa1uUqYQWKbLsbTWVJbL0V0QxeZJcsBUwzb8UAbmfujJzD9pI2I
         Piqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXGxi+w0vA3S2vk5VwyscfHKpZG6d0WokRKI8NpaBeBiacwMfO5
	AddRE7LmQHPMH1JJWBq920zJF5nXHWmHXEXjoGQl5fcoHNOAEpxaNASO6OFvbayLDSfpCoNpoE4
	u/tgl+iYgV9GjWeK2QlMqKgkeSCKMAD1ITBRFITBEqNhhWvcLfYT8aIfoCKCrwIChFg==
X-Received: by 2002:a1c:5f06:: with SMTP id t6mr24687017wmb.7.1555363259997;
        Mon, 15 Apr 2019 14:20:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVak01TLeUpHhfOyy5K50DHqpqJMci8+xy+Z9+AR1B56uzld3rPE+Aizg9PIO4yXqAb5mn
X-Received: by 2002:a1c:5f06:: with SMTP id t6mr24686977wmb.7.1555363259113;
        Mon, 15 Apr 2019 14:20:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555363259; cv=none;
        d=google.com; s=arc-20160816;
        b=Njt0892b4SDmI311Uz+0GVMzC5ILhp0VbuLnkPBWPA1oIQRlT73w3b21gYn20Tss46
         HykAVu+CofyktO79FnH9Hfrwyhuhbk6bGTrMb2LvZgqKxZ4o6xzwVLFekooYMR1DVnYQ
         tiycokc9FSzxJVwRHdUklzEn01xUsxdT6/SLevHpicVoXHE/bQFcXpK8/GTTWzIxtBiS
         JFsLjTCPL6HaDHxX2eaolyVuKgIxjqOonzhesxS+h5DX3aG/47QC7VPGRcVPuHznNePM
         XtcWDhAt5ghnz2CLLcEA9hJK+9wl0Gxv3bv4ln6DCM+01IJ03Kjxd+cG1sjSwPm59jHE
         64vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=Kma0HeNKyiBVfrxk4GuJGuQWMIqSyQzZCi/jszJ9/jA=;
        b=V5x/R4wOcpvVPy853AVAKVG8fILtvOazpuYdnmcn/AOHa20DyfWXniQlYKsowdOL+i
         D3uf5ZhrJa1Jx8akQZlFqw0fnkZMxvnMQ+OY7rQeDeaXy2eynepvUQt5WLMKl0R+bjDy
         0E4/c0vAkOWxwFNaMywkUIeRnaH3fOvaXYsNuPpZMyk23Ql2Q0szVqLRouV1f6x85ifX
         ss6ufdh0fUaXe3olqzjRi8K49tH/aM6WAKJTdHmvxS4C4Ho+QyuUquqXLHBVRBlBlWly
         YJXj4EkkC9xkP6PCb2cATK/CB+TuOwSXJrEVNzHZq/GngfSDWXmSFW6DlXQOYRVbYpcd
         xH2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id t7si33158450wru.186.2019.04.15.14.20.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Apr 2019 14:20:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef12d2.dip0.t-ipconnect.de ([217.239.18.210] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hG921-0005rk-Hw; Mon, 15 Apr 2019 23:20:49 +0200
Date: Mon, 15 Apr 2019 23:20:42 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Josh Poimboeuf <jpoimboe@redhat.com>
cc: Andy Lutomirski <luto@kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
    X86 ML <x86@kernel.org>, 
    Sean Christopherson <sean.j.christopherson@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, Linux-MM <linux-mm@kvack.org>
Subject: Re: [patch V4 01/32] mm/slab: Fix broken stack trace storage
In-Reply-To: <20190415161657.2zwboghblj5ducux@treble>
Message-ID: <alpine.DEB.2.21.1904152318020.1806@nanos.tec.linutronix.de>
References: <20190414155936.679808307@linutronix.de> <20190414160143.591255977@linutronix.de> <CALCETrUhVc_u3HL-x7wMnk9ukEbwQPvc9N5Na-Q55se0VwcCpw@mail.gmail.com> <alpine.DEB.2.21.1904141832400.4917@nanos.tec.linutronix.de> <alpine.DEB.2.21.1904151101100.1729@nanos.tec.linutronix.de>
 <20190415132339.wiqyzygqklliyml7@treble> <alpine.DEB.2.21.1904151804460.1895@nanos.tec.linutronix.de> <20190415161657.2zwboghblj5ducux@treble>
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

On Mon, 15 Apr 2019, Josh Poimboeuf wrote:
> On Mon, Apr 15, 2019 at 06:07:44PM +0200, Thomas Gleixner wrote:
> > > 
> > > Looks like stack_trace.nr_entries isn't initialized?  (though this code
> > > gets eventually replaced by a later patch)
> > 
> > struct initializer initialized the non mentioned fields to 0, if I'm not
> > totally mistaken.
> 
> Hm, it seems you are correct.  And I thought I knew C.

:)

> > > Who actually reads this stack trace?  I couldn't find a consumer.
> > 
> > It's stored directly in the memory pointed to by @addr and that's the freed
> > cache memory. If that is used later (UAF) then the stack trace can be
> > printed to see where it was freed.
> 
> Right... but who reads it?

Indeed. I didn't check but I know that I saw that info printed at least a
decade ago. Looks like that debug magic in slab.c has seen major changes
since then.

Thanks,

	tglx


Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D822BC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:18:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E57E20652
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 08:18:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E57E20652
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC0186B0003; Tue, 23 Apr 2019 04:18:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E47F66B0006; Tue, 23 Apr 2019 04:18:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D10FF6B0007; Tue, 23 Apr 2019 04:18:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 82C4F6B0003
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 04:18:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j3so7537040edb.14
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 01:18:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=ssy+vPzAYHn9JNrAXQFH+zLsnUKqZr4mvymfXSSr7D8=;
        b=cpAV7p9T1R2m3SuwWdvUfa/OrM+sYRizubxk3vf2RGLzkWy8YVyNIzMfdeztp0EKXn
         7arjo1qmfVyHSPPbEUdg8XdAsMoKCu5ySPW8ZJ8QRkqDZgMNf9bSCktMUqeHgaFfIRzB
         glD0nAU8AmGw+8WVz9o+DbCOJf5UoP9pYn+LprqXZC+KpjApY7He12W44eiuRt6soYcN
         0LIimG39aJMmVemqr7Ao9c+ogMD4P1CJNECiNH+6p+NpeE3yh3s44SwI6uQ/9KH3ITVY
         J9o91C6LjRnrRJHdVg38+aXr0rTU9JbMfSySpwqaK9VykfXVEYfGDuliFIw+MGCfay0H
         hG/w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mbenes@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=mbenes@suse.cz
X-Gm-Message-State: APjAAAWe64fPe6im9fUTtSCifdWosNp4HMwoXhC4wuyJRBuP8MkkCPLB
	VktuJRrbwkKO6/T/tYgk/OBI4a/+nHualj0mgIKPAzpQebIOLG510LDgMsdzJ0Rv/u1LAxu/+Fs
	0gzc9vf8JMCYIuMHmTQQPwiyN/7hOke1cn1WWIqmavlw7/s8erov4HZnBaFtJhUNsAw==
X-Received: by 2002:a50:9a21:: with SMTP id o30mr15062011edb.253.1556007525025;
        Tue, 23 Apr 2019 01:18:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztWivOhvU5I4C+ficAOs9n+ijK/5UJXBNkENZqfM2tJuRSp8OMrqfI6YXZSD1zHvuzKD4D
X-Received: by 2002:a50:9a21:: with SMTP id o30mr15061967edb.253.1556007524097;
        Tue, 23 Apr 2019 01:18:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556007524; cv=none;
        d=google.com; s=arc-20160816;
        b=gIaSm4vcPEMSM9dILGTYhttxiO5mqCIJ3hXtcF1Gc4fY6MwCQNH2MZr4C+yVQ4d41v
         nANNGZdpKk5I0URyTeaeaMDzXYDo4LsQhOd50bMF4CYTKKrIqO54b0Ek0SXrcHz+ndAM
         so6SiIXPcgm+Z3jouy7+vEZm9innF8XcUzC4yPgxBxulivg+clA7sjO3Q0rF1H+p1VT1
         ZogEq0uPtSjboZAF+Us86j2WW1BtpJMHsu0eMafNSjKRRjhq2BeGsnxwq3ui377eftu5
         dHcJI1nPGY63mum4ZFXxfcumO/0/NVFnVnhRB4A0+MpVUclIBZCc+Eyhf78oVgS277UT
         g+7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=ssy+vPzAYHn9JNrAXQFH+zLsnUKqZr4mvymfXSSr7D8=;
        b=lhfh1+qTfF2HvzZNtEUrXga5s+nPWM6lZfa9/QAayZJfscGo4nCWfVasNIKID7y0PY
         HVexSC+oWnfATeTdWeRNZc73CXXZ98CepMwkXNqRjVlN7/Fp+ltfXHM+GVyEGa02ghTT
         J6yt2J52kkhCqAIeQFAqbrpogsgpQXdEQAYfpX+iUb7TR6MJJfBpKBNnoZRM3pMQ4k9W
         TD0M86FNeSu8SB7f0YDkcydBTBn7ouPlbZ5IOv2A10dq6stLrP1gMlvyalQac9phz33Z
         ULlPrC5W8QO9lp4yf0iHcPLEAoEwPcXniqpqDFcq0WBB4w8S4ydhggb9zbd2A08Qloon
         qM8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mbenes@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=mbenes@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o18si3208381edf.59.2019.04.23.01.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 01:18:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of mbenes@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mbenes@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=mbenes@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id ABA26AD92;
	Tue, 23 Apr 2019 08:18:42 +0000 (UTC)
Date: Tue, 23 Apr 2019 10:18:39 +0200 (CEST)
From: Miroslav Benes <mbenes@suse.cz>
To: Thomas Gleixner <tglx@linutronix.de>
cc: LKML <linux-kernel@vger.kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, 
    x86@kernel.org, Andy Lutomirski <luto@kernel.org>, 
    Steven Rostedt <rostedt@goodmis.org>, 
    Alexander Potapenko <glider@google.com>, 
    Alexey Dobriyan <adobriyan@gmail.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, 
    David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Dmitry Vyukov <dvyukov@google.com>, 
    Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev@googlegroups.com, 
    Mike Rapoport <rppt@linux.vnet.ibm.com>, 
    Akinobu Mita <akinobu.mita@gmail.com>, iommu@lists.linux-foundation.org, 
    Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@lst.de>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Johannes Thumshirn <jthumshirn@suse.de>, David Sterba <dsterba@suse.com>, 
    Chris Mason <clm@fb.com>, Josef Bacik <josef@toxicpanda.com>, 
    linux-btrfs@vger.kernel.org, dm-devel@redhat.com, 
    Mike Snitzer <snitzer@redhat.com>, Alasdair Kergon <agk@redhat.com>, 
    intel-gfx@lists.freedesktop.org, 
    Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, 
    Maarten Lankhorst <maarten.lankhorst@linux.intel.com>, 
    dri-devel@lists.freedesktop.org, David Airlie <airlied@linux.ie>, 
    Jani Nikula <jani.nikula@linux.intel.com>, Daniel Vetter <daniel@ffwll.ch>, 
    Rodrigo Vivi <rodrigo.vivi@intel.com>, linux-arch@vger.kernel.org
Subject: Re: [patch V2 25/29] livepatch: Simplify stack trace retrieval
In-Reply-To: <20190418084255.364915116@linutronix.de>
Message-ID: <alpine.LSU.2.21.1904231014200.19172@pobox.suse.cz>
References: <20190418084119.056416939@linutronix.de> <20190418084255.364915116@linutronix.de>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Apr 2019, Thomas Gleixner wrote:

> Replace the indirection through struct stack_trace by using the storage
> array based interfaces.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: Miroslav Benes <mbenes@suse.cz>

Feel free to take it through tip or let us know to pick it up.

Miroslav


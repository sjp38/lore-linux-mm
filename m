Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.4 required=3.0 tests=DATE_IN_PAST_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87CE0C43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:32:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FFE22075E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 21:32:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FFE22075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E475C6B0008; Mon, 29 Apr 2019 17:31:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCD166B000E; Mon, 29 Apr 2019 17:31:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C704F6B0010; Mon, 29 Apr 2019 17:31:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA59F6B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 17:31:59 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id t63so10201111qkh.0
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 14:31:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=IJt5IAQjY0a+Q9eHHAinNnOWVMDs4eBkQV3mrl5omyw=;
        b=GFS6P3TBo/sh3lYPqH1ini9T7dVc8In46YZBoIl+3ntMVbAB3I1cQQXjRtiqzQF4QC
         +fKojGQfFVyKpy9EUjEUmcwaPjqIfzFAPr+YPGAYrat9LcigJy9NdfAz5v8Pu936XkuZ
         vnXVTq0OdzsKkPRayCz6Id/VvZMTBLOHASxhSSEIetZpxePHPMPLIDvGLavtadtkvrK2
         +wdr3XpF058FEKoVKKCVXbGq0a3rJyOEjal0IwMKafIygB9yXx1BxazSTAJ6nXNqJDZH
         sJ3lPLtGvlok7z/yvgtLToKeSesiEsq7vt5teQG0IDGvRkyHujqYAG/6y9Kfc3ixMUB4
         MWuQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX8ZWfoH4LcgYBGFqeC61/GTCwt53RU5ERbl4479Ka6/mYdQR1W
	/PSsoVIOpVdZoykrH0dnE1UlTghap6nFMZCcq4iU+S3TBOf5uhJp2ceFYVOmsXfLitZOblC5Mal
	0StOjjZpXv20yWt1lrJFa9OjD+tWB+xMWHTNIz3cIMOnIOh/sTYHwmrY0ISZN5nRUAQ==
X-Received: by 2002:a0c:92f9:: with SMTP id c54mr20128544qvc.194.1556573519457;
        Mon, 29 Apr 2019 14:31:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuW8mJF6GFVebHmVkKLl9+efmWz/zHkIE0NgviL9BYOCFXnoD6Zfz/DFQcyj6xOOTq211v
X-Received: by 2002:a0c:92f9:: with SMTP id c54mr20128515qvc.194.1556573518973;
        Mon, 29 Apr 2019 14:31:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556573518; cv=none;
        d=google.com; s=arc-20160816;
        b=WgXgm3DUeZ+hXjM7X8mV9gGpL+S2V0yWrHPqkcMsBEBuaVxCtP+jhzaVnvaRIB3wDO
         wJgp0c+g+Q3QAIGiGuKbL4np/9Rc0Vrxf70otHEL3PYRrH9m8L6h+fGlUGIFvHDUrHcq
         +9bU4e0/e1B5CXSWXnTF+8BTw/Zv9KaIg0Mz0JlthQMVDmr2fpmm1kIIKvMkv/oQMjRg
         MXTBNnHGNzEsulu09sK93ihyvDAEfHScBLzUAg3/Nur3PVlHKSc28sZ/7cRUhbmkUXyV
         OlQoLdc4I0DLV6sqK0qTR1qXNyh4VbKOfs0YzAwACI9Z0q9gz4pSjaaFcQkIRpYVSERa
         HQdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=IJt5IAQjY0a+Q9eHHAinNnOWVMDs4eBkQV3mrl5omyw=;
        b=MWAiAHXVciARL5i9VqUKS3HzvXnbZqfUMYA/P4YOnIN01Mz3hBiyj3fTQm24CCjI9W
         E12c8H6/X0Ug/BzlIIRjEqyo3+4Rm9hl8KQcm6ZAUp2GnbExDWZtJKlfrxxEyEmwECMA
         gmWiMD8nTsa+PIbPe61PFCvQUFl26dzC8fO3iXs0qTePZwOnmbCcznpame2lZ2Uk1N3Y
         W/KBD+KSXLrXA0Nvz+e5HHGgZSaFUkGdwT3Y0rzIQ+FSBhjdB19HVAUvMzMPsCAOtx8b
         /zcY1YIbWJbi8oELhBC9X+tph3kBRAzCsbxalj0QWfrI+bEcbPwQDXlLOvRzZA3kzKpI
         JS3w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y12si2904848qty.70.2019.04.29.14.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 14:31:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EEDB9309D28F;
	Mon, 29 Apr 2019 21:31:57 +0000 (UTC)
Received: from ultra.random (ovpn-123-98.rdu2.redhat.com [10.10.123.98])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 242D45EE06;
	Mon, 29 Apr 2019 21:31:55 +0000 (UTC)
Date: Mon, 29 Apr 2019 10:37:11 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
To: zhong jiang <zhongjiang@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
	syzkaller-bugs@googlegroups.com,
	syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Peter Xu <peterx@redhat.com>, Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 1/1 v2] userfaultfd: use RCU to free the task struct when
 fork fails
Message-ID: <20190429143711.GA11265@redhat.com>
References: <20190327084912.GC11927@dhcp22.suse.cz>
 <20190429035752.4508-1-aarcange@redhat.com>
 <5CC69B6C.9090608@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5CC69B6C.9090608@huawei.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Mon, 29 Apr 2019 21:31:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

On Mon, Apr 29, 2019 at 02:36:28PM +0800, zhong jiang wrote:
> if we disable the CONFIG_MEMCG,  __delay_free_task will not to be used.

Yes, the compiler optimizes that away at build time.

Thanks,
Andrea


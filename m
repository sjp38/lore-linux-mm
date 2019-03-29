Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54A56C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:37:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C85221773
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:37:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C85221773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C70066B0269; Fri, 29 Mar 2019 05:37:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20036B026A; Fri, 29 Mar 2019 05:37:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B12006B026B; Fri, 29 Mar 2019 05:37:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B2506B0269
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:37:32 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c40so791184eda.10
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:37:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZuNYJ0STAOox2fW6u6xv5rOLr6thWOhW3nr4cC0YhHA=;
        b=lIKkyCKiDBd9qFXw69WtxFd+UPdOfPzzD166ywnzUZZ9F2e3KpAZDLUiWXmGW97MC5
         6GkLf0FdYh6UxSoKVR6KQflVWWYH41MQeKjOdQY7SJ8rp7Fa+RSy06bW8KwV23G9DkXD
         TQist9pKz/2jsb8bzvXcluDN6/T3FXv/EwweevpQZydpurjpmnjtgrJ5Dzq+NkgUCnX2
         E+Jbxngw+gkxzlFQd4NQHmUPMePSQy5Ap9xeMSUO2vU1I+8vCWphL7MdvCll8bHiPg8A
         Bvz6GqGQ4ImhcJOVfnOR59MSdTIQAAof0CQTFKPvZnUlNexaPWp3DuA6+leTZ9DipLoG
         nidQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVnPYPD+uoYAFonsrLjPKzoP0z+RF7vLjNtA+s7yux38kg7iNGm
	2gdDQSHHoJd3f1qoAeS2WE3aD7na6/IaG7iBNcsiwsOBPf26IFtlEqlBlE87lsVKNTpN7n87s2U
	IRV4+tpeb1bR/2neB/xyP9cDP2wJRlURGdOgX6QHTKn5QazdBTxcWbGncD9bcDLE=
X-Received: by 2002:a17:906:b6c8:: with SMTP id ec8mr11690740ejb.89.1553852252056;
        Fri, 29 Mar 2019 02:37:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/I1D/AIhguMtuUjYaNoLJ81AwAzCfYdM+FTHjVnommcRZFRg+2JgvMGBGOzGhGSSQth5+
X-Received: by 2002:a17:906:b6c8:: with SMTP id ec8mr11690719ejb.89.1553852251286;
        Fri, 29 Mar 2019 02:37:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553852251; cv=none;
        d=google.com; s=arc-20160816;
        b=n0dGaaasiTh6iLcOIK7XJ4Qz+/svKxJRWtjOyuRni3qss/Ao+NATObuIvqDXzduOrf
         u0FnLRUULDmDM86sQhyWDE1MfKip4hzlKrFgSicDf1+cEicg8tLooYzgrh0IdIRfo5+Y
         ZEq1vw3HMytcIEeCyKsFJxqeaB/A2POKazPBiwYvENE2+5DgedMHWVTw6USdKbm6RxMg
         jE6apgYMplKK0E2DToBzJCNRN+shtrh+64prLcrW+srFGyafGTPd3cMoR/BXHJImEeeE
         hSPDgArL7SYLmiI6uaFXJtQQxyFyFCp1dQbg3/flHA2w3qHFHi+HsD6nDBW3qckkEeff
         ix5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZuNYJ0STAOox2fW6u6xv5rOLr6thWOhW3nr4cC0YhHA=;
        b=xaLo9PdsmUfNe+720mkAWM9eg7TSbuVSiHd2mNSW6jk442g7hA11WKx3J+HXtIjs1Z
         lAEk0Kp8ajydJ7oI4uRGsEmt+RyhdcilsDN9xVGJrKNTgZbn+g1tA89zrrJNdiZxu9vp
         g1hGM6wb3UCp2Ji2IDI2oO+x2Omdb8HVimo58TgWGVGcWs8p5EbhcCreE4X7+n1uN+Sd
         F2L8rVC4M6rSBLh2oLzUwRpdiCawiHg8Fo/VnjmTI8GC50mwqV7CaH+AUbPQo1eNuwvp
         5HvElKLLZLrBwvI5093rVCEkbIyptt8MoNAjYw/++P0VNsNSNXU9afxX8oT8P7SxOobC
         W1zA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id t10si287526edf.341.2019.03.29.02.37.31
        for <linux-mm@kvack.org>;
        Fri, 29 Mar 2019 02:37:31 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 8CF184743; Fri, 29 Mar 2019 10:37:25 +0100 (CET)
Date: Fri, 29 Mar 2019 10:37:25 +0100
From: Oscar Salvador <osalvador@suse.de>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baoquan He <bhe@redhat.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, rafael@kernel.org, akpm@linux-foundation.org,
	rppt@linux.ibm.com, willy@infradead.org, fanc.fnst@cn.fujitsu.com
Subject: Re: [PATCH v3 2/2] drivers/base/memory.c: Rename the misleading
 parameter
Message-ID: <20190329093725.blpcyane33fnxvn7@d104.suse.de>
References: <20190329082915.19763-1-bhe@redhat.com>
 <20190329082915.19763-2-bhe@redhat.com>
 <20190329091325.GD28616@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190329091325.GD28616@dhcp22.suse.cz>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 29, 2019 at 10:13:25AM +0100, Michal Hocko wrote:
> On Fri 29-03-19 16:29:15, Baoquan He wrote:
> > The input parameter 'phys_index' of memory_block_action() is actually
> > the section number, but not the phys_index of memory_block. Fix it.
> 
> I have tried to explain that the naming is mostly a relict from the past
> than really a misleading name http://lkml.kernel.org/r/20190326093315.GL28406@dhcp22.suse.cz
> Maybe it would be good to reflect that in the changelog

I think that phys_device variable in remove_memory_section() is also a relict
from the past, and it is no longer used.
Neither node_id variable is used.
Actually, unregister_memory_section() sets those two to 0 no matter what.

Since we are cleaning up, I wonder if we can go a bit further and we can get
rid of that as well.

-- 
Oscar Salvador
SUSE L3


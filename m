Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBA5DC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:31:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AF3DA2085A
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 06:31:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="V58GbM/I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AF3DA2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 400686B0003; Wed, 26 Jun 2019 02:31:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AFF98E0005; Wed, 26 Jun 2019 02:31:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 277358E0002; Wed, 26 Jun 2019 02:31:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 031B06B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 02:31:17 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id o187so3461363ybc.11
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:31:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=XvuBLXcrOw2ujcFIhg3xlNpbLeOa8msaysbBWvdKLzg=;
        b=m7UGWsnMB7Z8ZgYsp2/LX3Sij3FKajcaPiECVkiNiS9YFEF2iZcuB36HLFtn1NwYrC
         RAkzv//uVewPu756RbjTlg5dIeQpQi1VK+NFYcz3uUYjq61vaBXoJOqMUgQhbXoKbwUK
         0VHmgzj/EV6m3u8UnYmklsNp2vCtmJwNbsgDr1V3Dl7/3CmMl9UbD0G0rd3sfdmKlBHl
         XpcFvRui9igWKjofhN8QvJnD4CwJLQADmjoi7F5/cyhWHv2DkVU0ZEPWSeHPI+UoAlFB
         /EWDvw5/v7cYyoqttTZ2J62X3ytOLmwcL/InLSEAoeaKhjtG+sTEfFVEF0eIlEckJnNi
         MoZw==
X-Gm-Message-State: APjAAAUIoOJScVDU2wdd97JGV5Y6w+ssCbgv+BiPVMZxBcQ6NX7mrFBm
	vbau6Bj3Q0yvo/NoWdpgA+OSRtGSG0EdfkyUDKOcKH3iUNi1DP9BmEShO7a4ZfFPnHVba62+GC0
	sgns8hqn+wqq1IfSG7COk5Rr663in2XdB6uXSxDcfpdoffFvjY/i9IFtZ+0dtgmStTA==
X-Received: by 2002:a81:31c5:: with SMTP id x188mr1681326ywx.429.1561530676768;
        Tue, 25 Jun 2019 23:31:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlFYYdSXlxSglSf+m+GftBQAO2U/XvIqjl5pOnwQCFvbDTZL6amUghzX73YsI8IsSYZy5o
X-Received: by 2002:a81:31c5:: with SMTP id x188mr1681306ywx.429.1561530676284;
        Tue, 25 Jun 2019 23:31:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561530676; cv=none;
        d=google.com; s=arc-20160816;
        b=PdTCSVC8MM8NL8jB4sxzhtysb7MLBZbbZExb52i7uFyQiuHEFcfixv7Nkst5QiYxq8
         m4jV5keCaeAZnRfn5ZRwZ4nyM7o0dE0wNZ08uCl+rouwPCwE8SL2UftJT9BLHKO7wPnO
         kxzLmQfwmYtZjiOkuyvFdvNQ0mB3UDOwAdDTvjf8gFbOnpve5w4cuqEL7f+z2iW0qLnB
         VumT9H+XyUeX7KzPtQ3O9FwxcB84SZTpp6PXtvhRpe/KzEG1PSdxf2vdpIZM04Lcysks
         /SC2Xwt4ipdECAs998wzuWY8800UcE65TFb3YR3l7Mkh3tlG8fedpQeBznNqGqzlydrL
         IYkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=XvuBLXcrOw2ujcFIhg3xlNpbLeOa8msaysbBWvdKLzg=;
        b=Z4HflDGs4Xn1r7I28CjkshSQ60HpcD58nras0hdCmTG1iJvzfaBgX2QZvgyLhfzLQ7
         5H+zXBQVZ7GEnQoSLuza9swrT/jYjpawQ9G7Xi1PSGO3bhYsT0ZvBptVGx1M8tc5vOcR
         O2n3i/fWKGguWzfxfFw8YAxBTPlSANibgPmzwPIPN02RnUWqTaVeXeELVr/+6bEgKY0O
         TFWodC8miHTuBkbXiIb/biiBGEePDfWjE7iS7ZQDtE3y7gLpReMBN+CUNo98rQNe9zNm
         VJJW0pixG5871T3T3AhIZjQ1WUBgvQt4Hf+CZ/5psUirLQDLfSsSH99S7I0s284WycZA
         1VkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b="V58GbM/I";
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id a18si6041211ywa.71.2019.06.25.23.31.16
        for <linux-mm@kvack.org>;
        Tue, 25 Jun 2019 23:31:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b="V58GbM/I";
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 7D6B32DC68FE;
	Wed, 26 Jun 2019 02:31:15 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1561530675;
	bh=UI2GCXuBlxHgc850F1IfwNc+nsesrzgc20uhDpnUNSA=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=V58GbM/IaY8yJHTevGM2YMXWyvjz94zsRDVbk87BElo745K17gBhdRcNgKLyMp0Yu
	 rrw8xk+rDD4ywtCaqoDh1th9okWQJbDyeeAfJedEb6iEG9LcCd0Z/Oqu8e6g0zYszq
	 jeeKBvDLHmjjwjclNcHZyNiGvGida3Vmdgu3v6K/ceJnScMvFHnI6OEdoAxXT7pKwO
	 7HB30vulphiiJ4hzta0WhmAs8gk6cyi5VK6HXy1X4aVpHXbjdx/3AyUHola0fRGjDJ
	 CiUnNQaaZwXn/gB/A+OlyuBWbLqnK5E1zTy9sYSPRBfPG81UiGiZPFBeie7g02QBFb
	 pDjgk3iqHfG+pX86sLyYH83bBo9Tcx/2eqc252x+WoCBlpeNIMfMib9bS0KvkQ4kJU
	 XSwpA7y0zzLE0Pg/lf6VxvRlfycnyivQGb6YYlqGp4qMvqm/JOu8B3mnj1/JUohSwz
	 CsZuFjyNo6T7eMj2v3TqMdu8HcVnGDn5YjXg3WNXNLy/X8Dr5W91drGLRDIUlNqGTk
	 vkB1zB+88tPhhHoAEQPhwRptORM4WyMZSaWTpyIERpvw6H5p1zxmi7Xpr55oBP1QzH
	 +38aqqzjJ/D+OdzV9CM3bQEFg7PvAf3rddF5+52jA+kXDnYWZU0q5bHoiSAuI8LjvD
	 hSehiItyqMXEbkOEOwvSTNTo=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5Q6UtdL031388
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 26 Jun 2019 16:31:11 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <edac179f0626a6e0bd91922d876934abf1b9bb19.camel@d-silva.org>
Subject: Re: [PATCH v2 2/3] mm: don't hide potentially null memmap pointer
 in sparse_remove_one_section
From: "Alastair D'Silva" <alastair@d-silva.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "Rafael J. Wysocki"
 <rafael@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Pavel
 Tatashin <pasha.tatashin@oracle.com>,
        Oscar Salvador <osalvador@suse.de>, Mike Rapoport <rppt@linux.ibm.com>,
        Baoquan He <bhe@redhat.com>, Qian Cai
 <cai@lca.pw>,
        Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org
Date: Wed, 26 Jun 2019 16:30:55 +1000
In-Reply-To: <20190626062344.GG17798@dhcp22.suse.cz>
References: <20190626061124.16013-1-alastair@au1.ibm.com>
	 <20190626061124.16013-3-alastair@au1.ibm.com>
	 <20190626062344.GG17798@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Wed, 26 Jun 2019 16:31:11 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000010, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-26 at 08:23 +0200, Michal Hocko wrote:
> On Wed 26-06-19 16:11:22, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> > 
> > By adding offset to memmap before passing it in to
> > clear_hwpoisoned_pages,
> > we hide a potentially null memmap from the null check inside
> > clear_hwpoisoned_pages.
> > 
> > This patch passes the offset to clear_hwpoisoned_pages instead,
> > allowing
> > memmap to successfully peform it's null check.
> 
> Same issue with the changelog as the previous patch (missing WHY).
> 

The first paragraph explains what the problem is with the existing code
(same applies to 1/3 too).

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org



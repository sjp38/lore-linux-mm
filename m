Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA4B8C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:02:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 995FF21871
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 16:02:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 995FF21871
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30F916B028B; Fri, 15 Mar 2019 12:02:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BE996B028C; Fri, 15 Mar 2019 12:02:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1D6276B028D; Fri, 15 Mar 2019 12:02:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBF096B028B
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:02:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d5so4044772edl.22
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 09:02:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=KeK2qaiwed6RFlNvBsOf0J+3gjNgBakJVUpnigEi2BU=;
        b=WO4NqhxS9nQFMdachDbam82UCg1ZPE0ZlvNv5hPKxhXJ7vJWBnz+kkbhWQEkm0NjBK
         0M6LGnpoO7rDPoOAoOfUkciSbBP5egeiftMC5ERXiwOBWaZVRvw8hGBI/SZOcvU7s08/
         7vO7Y2gUCZp2NAVTIRD5o/041+Ym9aLdARzJr5bM0v7hSAjUixldWlV2fdAUcZaxdPc6
         p3n3Y2zyd5tRV1HUHNYN6AzxTplwI2qemc6vxc0jZ6S3pjJuC9WuTc5oNqVD4jBer60a
         UCVLp9SHY3d+jKePDt9hrl66ZsTz8cghmDJ7L8LR6M3PSB6jM9zpIdw+f+DZTS1u4H/q
         iaNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Gm-Message-State: APjAAAW/OPrx7M72bsawdO6Hpo3KvMn/8k17BOf+cep7HRSKtUOmduLb
	dAH7hPTjAK6cn/Y6Jwe8EL3n00JU2WjZ7nKtKJ8iOq5lfpyBHCxXApE5xhCkppyVF+zoaVjKer9
	HaAnAYcWXjw43DzuJK3mau415AbshQJWpuXm54TFyG/6T1s9YnZSYerS9acmki6M=
X-Received: by 2002:a50:b493:: with SMTP id w19mr3460336edd.11.1552665747273;
        Fri, 15 Mar 2019 09:02:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwpe+5DQDZ85eDDgDsWgs1kq/PrHMRKbWiF3aKAV6GFr6a3rh0pMXvXUmbUjazmvYOAN42s
X-Received: by 2002:a50:b493:: with SMTP id w19mr3460274edd.11.1552665746211;
        Fri, 15 Mar 2019 09:02:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552665746; cv=none;
        d=google.com; s=arc-20160816;
        b=lt/bavlbmv/PON8Fmc27noA1QPtK3KjjqBZTDARULeLevglv+HS/esovi1Y8P5pa/4
         0TCOAFrgPq3Y0En1r3+NdkMbsnabxaYzYdjhftlIwg8kKi18bOopK0wAFduSeHTpyWou
         Hs0+Ub+akuK5CKqxJ9w8NC3XrnwMQeZIXjKeInX4vRqjder7ClA0qm+goIgpAKY/JT0g
         K7mXF/Rp+17bkc5hEvsLeL5Hs6JFF/ZOhTEilCW87mtBswsYbr/pUquUMY+na5FmxH61
         JTAedTcEr/Luvm7QezKbS5fxtZSqxwd1qRfacjeWyNsoPMgBSv5sP1vrqi9Q+Z06pSjT
         IRLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=KeK2qaiwed6RFlNvBsOf0J+3gjNgBakJVUpnigEi2BU=;
        b=hEkshqz2wA1s0HzjPG87FaciJzBldeA2GPSXUcvL6WtGVSNX8ri8jI9EXu/X9wJNfS
         sE8X64xwoLrSDZ4hMS2IJ5keBiFqjGay9rsi4AYy5RT3A9TF7wjDOxkT0UUhjEj2xa9J
         amgYciEtb6Zg+QtoxIOpDXsUALIzyHkGdu7DzX8k+8BQjS93TkLdIhFNSgJ5NOyxzPfK
         2Ca2iKpoNvzFXItQwIiP2A16kNQeG/fOrxN1XD9D4u233uO7bLdcEXrujeFyz3BQeJdA
         T30LQZ+FvfgdxNGCYtNAov9WrmwzahMupFGCk6M7EFERZahoFmkFc88hbkYEARV9sfMx
         9/KQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gy20si917380ejb.211.2019.03.15.09.02.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 09:02:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of metan@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=metan@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 73F9EADBD;
	Fri, 15 Mar 2019 16:02:25 +0000 (UTC)
Date: Fri, 15 Mar 2019 17:01:42 +0100
From: Cyril Hrubis <chrubis@suse.cz>
To: linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>
Subject: mbind() fails to fail with EIO
Message-ID: <20190315160142.GA8921@rei>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!
I've started to write tests for mbind() and found out that mbind() does
not work as described in manual page in a case that page has been
faulted on different node that we are asking it to bind to. Looks like
this is working fine on older kernels. On my testing machine with 3.0
mbind() fails correctly with EIO but succeeds unexpectedly on newer
kernels such as 4.12.

What the test does is:

* mmap() private mapping
* fault it
* find out on which node it is faulted on
* mbind() it to a different node with MPOL_BIND and MPOL_MF_STRICT and
  expects to get EIO

The test code can be seen and compiled from:

https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c

-- 
Cyril Hrubis
chrubis@suse.cz


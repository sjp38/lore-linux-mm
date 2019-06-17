Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69BCBC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:50:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 371652084A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:50:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 371652084A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DCC568E0002; Mon, 17 Jun 2019 10:50:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D569A8E0001; Mon, 17 Jun 2019 10:50:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1D718E0002; Mon, 17 Jun 2019 10:50:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7224A8E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:50:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so16733274edr.13
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:50:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=dEA3YnWQKVV/MWIa5Yuh0PUdlRXKRdfJtv3/Jm6bLAo=;
        b=NrdnU5imBJitcE/fwB84hjYZzqAdaI1pGMlLEMKrJ9XVzwJWPKAEoQhBQqfuXNmKX8
         rpdHTiRZss44U8SWPDsqzbYfMXljPIlgFuWlEy9pomhn+WudOD3h107OMzUbRTOrW6ur
         cVOpeTuJ5FAlhsZjXtr4LRVSrpq5cH1AU8znWwD9ktZe/KsTQn1czoDca+rNk/XNRKoM
         eZaCtmovAv/FWJPu7Wlkjo+J+c3VFt/77haL5a1pwIi782k1Ml6EZLV53dmMgGyrEUFx
         mBPvdu9vkgKG367qzgpFgcD8xhKVo6BKMhHu51pcH6K1y94+QTxTpMzxYZ0r6IbHQiBF
         mj3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: APjAAAWQz+ZvUpoX+weNdxVOEC0uAfpIS+6PntNJRNmQ/X5pTTQ5kY12
	d4TmRWOAoIdwZOYe7LfCq7NxmYWrl44z+z+8ix2YijA+kwpVETf2XlgKkJRsz73RoueZ1ELBwzX
	dMcwjuRiOMiYf7usdjqVPdjyu6djzd7VePZ1v8/m0Ha9RiLI+iwVJN5PVKioYMUWJzg==
X-Received: by 2002:a50:b104:: with SMTP id k4mr92838546edd.75.1560783020049;
        Mon, 17 Jun 2019 07:50:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSTsfzK2ynLGmpwURZ/3Fp4dBn7rYBbJnac3cKAQP+thI0ids0emvUa9OyJ226qp7kAoaY
X-Received: by 2002:a50:b104:: with SMTP id k4mr92838484edd.75.1560783019430;
        Mon, 17 Jun 2019 07:50:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560783019; cv=none;
        d=google.com; s=arc-20160816;
        b=VCcu7ADkQht//qkaP77LXFx9U2ThW/0URIIdze5s67V3a9xzb2xfmKX0qMcbrhBjs/
         NCZ3anVhDWH5aW5rW7nur7y0q35smNfEI1vXt9DQ6GWDRnuTJ6ZbRW3l9mtE5u7RVVQ9
         ZzbdPGjae3w5Dq9aYo2/iBxNeTbegavknkQ8tE7gO3AO1FZJKX4vrwmIW/xEhNdO9YQP
         cIF5YxUBKWDnw18BwpVtQ1DEdIR/TKlkkl7DIAmIq/nArenTR1Spo+LnrFShsXcygsKQ
         X1TkSLvBmVug6qKE8Hv0Le2/mUl7O6Zr+COH4vlXtPEs4EOeiBUYEthiQv/Q7hJf1E+B
         fI+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=dEA3YnWQKVV/MWIa5Yuh0PUdlRXKRdfJtv3/Jm6bLAo=;
        b=R8nK9KYrZa6lXrcf0n0EbKUx99k+o/nJjA67Xt98szzwK3B9r4AWaB6Co5WDYd44J+
         F6CSaTh6hvoOoJ/UrfBGv9tpjRTJRQciMR8yaQCT5wkCgVyi01SyWH8rZXOdqKfggPQt
         vRer9IYsRxcUHeRwAAPFacevCMR6KTxgQIgyHWr9AW/71WRc6PkPjjzDBknNwU9wG1Fh
         3HqpjQa/W5K5N5n1jt1kGYvgQIqsxygXcZO4IG8nLd+ejNKSqpsg4Vur3d0OvYVvzS0B
         1yY7Q8UggklZTJhzvdepC/Ltyp/mjBD9dfDEYy7Qsqsi5+TdnkYXysgeCqOjSNjcHsy6
         HnhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l56si9182733edd.41.2019.06.17.07.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:50:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6B7B3AEF1;
	Mon, 17 Jun 2019 14:50:18 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 17 Jun 2019 16:50:17 +0200
From: Roman Penyaev <rpenyaev@suse.de>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Uladzislau Rezki <urezki@gmail.com>, Roman Gushchin <guro@fb.com>,
 Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Thomas
 Garnier <thgarnie@google.com>, Oleksiy Avramchenko
 <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>,
 Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>,
 Stephen Rothwell <sfr@canb.auug.org.au>, Rick Edgecombe
 <rick.p.edgecombe@intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Mike Rapoport <rppt@linux.ibm.com>, Linux-MM <linux-mm@kvack.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in
 pcpu_get_vm_areas
In-Reply-To: <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
References: <20190617121427.77565-1-arnd@arndb.de>
 <20190617141244.5x22nrylw7hodafp@pc636>
 <CAK8P3a3sjuyeQBUprGFGCXUSDAJN_+c+2z=pCR5J05rByBVByQ@mail.gmail.com>
Message-ID: <fb05c3956eba18a8b01e8a8fa0396c7b@suse.de>
X-Sender: rpenyaev@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-06-17 16:44, Arnd Bergmann wrote:
> On Mon, Jun 17, 2019 at 4:12 PM Uladzislau Rezki <urezki@gmail.com> 
> wrote:
>> 
>> On Mon, Jun 17, 2019 at 02:14:11PM +0200, Arnd Bergmann wrote:
>> > gcc points out some obviously broken code in linux-next
>> >
>> > mm/vmalloc.c: In function 'pcpu_get_vm_areas':
>> > mm/vmalloc.c:991:4: error: 'lva' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>> >     insert_vmap_area_augment(lva, &va->rb_node,
>> >     ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>> >      &free_vmap_area_root, &free_vmap_area_list);
>> >      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>> > mm/vmalloc.c:916:20: note: 'lva' was declared here
>> >   struct vmap_area *lva;
>> >                     ^~~
>> >
>> > Remove the obviously broken code. This is almost certainly
>> > not the correct solution, but it's what I have applied locally
>> > to get a clean build again.
>> >
>> > Please fix this properly.
>> >
> 
>> >
>> Please do not apply this. It will just break everything.
> 
> As I wrote in my description, this was purely meant as a bug
> report, not a patch to be applied.

That's a perfect way to attract attention! :)

> 
>> As Roman pointed we can just set lva = NULL; in the beginning to make 
>> GCC happy.
>> For some reason GCC decides that it can be used uninitialized, but 
>> that
>> is not true.
> 
> I got confused by the similarly named FL_FIT_TYPE/NE_FIT_TYPE

Names are indeed very confusing, that is true.  Very easy to mix up 
things.

--
Roman


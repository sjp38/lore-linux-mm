Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B36AAC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:40:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7841320833
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 14:40:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7841320833
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23B458E0002; Mon, 17 Jun 2019 10:40:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1C3FC8E0001; Mon, 17 Jun 2019 10:40:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 094EB8E0002; Mon, 17 Jun 2019 10:40:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AC7E18E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 10:40:34 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so16709335edt.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 07:40:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=Zi0FEtnAXPogjxUguBmzgfI+w7Dmsl2S1Zfg6FFrqss=;
        b=OKH8bSWlz7SI4JRYbIkGYUe97LCK6U/CVqLxQWvKWRaewW3mG0vwr2AlAOjsmN/VSZ
         Z9p/qJFXpTLTZrMtWYJp4tLMkA/CI8TGw1a/34XfJ65crx20NQNvN6OWytG4fz08YWkK
         nr/eXLltfo16IEEsPkPTnAKPiqczL86zeJh2zK0XUjBArkkncgg0tddFZXlZ8vmVbxXP
         jRIZDSwVOtKdvc3ji/KMwVZIxLESdSp9vlUr6lTx75qi3gPCflLEw+xg6fZmxPGFrnFe
         adE9OEFyoKZEUFNOiAP4tv0ixXqoujQZj3jYARJo3op1hcaM6vxGPPQSpAOjOUvJ6qG9
         1ctg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Gm-Message-State: APjAAAUchTP04BPYORuVAG0LDCWF04N81Cx+aF7C6mK/g5kcK2WMNZqE
	WZ27W5Vi1iEVEnnVpwC/A2MSh00YRPCjsH/bOOGf92ODT4l5GTY7RxDCZQBdTAxJMjencBznGxU
	fyAAZkTu9wRQhyVDcDbXoj6RuKkQGahmTi2q/RJsjM7jmgmXfXsNjdGFTluDN/xvJow==
X-Received: by 2002:a50:90af:: with SMTP id c44mr91899854eda.126.1560782434253;
        Mon, 17 Jun 2019 07:40:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpLf+a3aRJy1Owo2ONkag/tRKWhyOp4AU3D2ker4A8Ja1++vC/8XIm4OG9+LQR3CFs7jrT
X-Received: by 2002:a50:90af:: with SMTP id c44mr91899778eda.126.1560782433520;
        Mon, 17 Jun 2019 07:40:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560782433; cv=none;
        d=google.com; s=arc-20160816;
        b=ybGCQq7dGDtHOI6PZl56BBioKqz4ERHGMCnpQvALjkcaRmXNlER5w7gyLYebeFVF1c
         ncYjd4tPEXGt5DJu33P1TLzqfH6aAy7GapUaDc/6ebo/Fxy4qTDSyfotc7nMZawtEZqh
         HlrcOwSSYR3Pnx6ZcsgwhMSHe57uOL3McxpItTiFUoUA49YX4uycpc+ayb+wOrKbsvu8
         CyHO/bhwhn/BmbSqTKN95d8PDA1f/69ccJgwyZgerOl5VTu8/hHsgwwiSZuOzYLca1pj
         cykp4J9mKeoNTgOYTztUZNI6jdzCFlPL8o4S8N+git78COvPM9VS5pSMnH93BKKuL5c7
         R8FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=Zi0FEtnAXPogjxUguBmzgfI+w7Dmsl2S1Zfg6FFrqss=;
        b=rK2arXWRNToho6R3UsPvv0rjw7yCRvTOLhm+ee+Q38iYErCIeFSaMKr5V097OxygQa
         wSHZUvuMAPskAgGjrQSlO6EuvOckcGjjyQ4cD8w/C8JVSzuDNmcFK3lPkkOXv9jE1QcX
         RFzk+kak8EhBqqn+NKXeGEm0eiQGybQQ0MwjF4Y1cXu/VeHlAxkurcZz0i4sE+tH9Z5W
         s/hnPphLAPdW4NzYssWeiI5IUMtLY3Aun+G9ww1MJOCFzkqZF3NZGmN9m7rWfEzkIHS9
         jk6WzcnqoAO63Otd6s2ZQl1NUHWbhMNhb9F0Ie/KJ0bDJsXS4bAuQ7WSUvwkC22nIP9+
         9LDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s10si7581561ejl.91.2019.06.17.07.40.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Jun 2019 07:40:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rpenyaev@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=rpenyaev@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D0D62AF60;
	Mon, 17 Jun 2019 14:40:32 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Mon, 17 Jun 2019 16:40:31 +0200
From: Roman Penyaev <rpenyaev@suse.de>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Uladzislau Rezki (Sony)" <urezki@gmail.com>, Roman Gushchin
 <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox
 <willy@infradead.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy
 Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt
 <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner
 <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo
 <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds
 <torvalds@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Rick Edgecombe <rick.p.edgecombe@intel.com>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, Mike Rapoport <rppt@linux.ibm.com>, Linux-MM
 <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>
Subject: Re: [BUG]: mm/vmalloc: uninitialized variable access in
 pcpu_get_vm_areas
In-Reply-To: <CAK8P3a0+jOW==OOx_CLj=TCsG5EBK2ni6kw1+PexJLAC2NEp_g@mail.gmail.com>
References: <20190617121427.77565-1-arnd@arndb.de>
 <457d8e5e453a18faf358bc1360a19003@suse.de>
 <CAK8P3a0+jOW==OOx_CLj=TCsG5EBK2ni6kw1+PexJLAC2NEp_g@mail.gmail.com>
Message-ID: <a05a92b2fdc7c8b7850e9e7c63f8e9e6@suse.de>
X-Sender: rpenyaev@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-06-17 16:04, Arnd Bergmann wrote:
> On Mon, Jun 17, 2019 at 3:49 PM Roman Penyaev <rpenyaev@suse.de> wrote:
>> >               augment_tree_propagate_from(va);
>> >
>> > -             if (type == NE_FIT_TYPE)
>> > -                     insert_vmap_area_augment(lva, &va->rb_node,
>> > -                             &free_vmap_area_root, &free_vmap_area_list);
>> > -     }
>> > -
>> >       return 0;
>> >  }
>> 
>> 
>> Hi Arnd,
>> 
>> Seems the proper fix is just setting lva to NULL.  The only place
>> where lva is allocated and then used is when type == NE_FIT_TYPE,
>> so according to my shallow understanding of the code everything
>> should be fine.
> 
> I don't see how NULL could work here. insert_vmap_area_augment()
> passes the va pointer into find_va_links() and link_va(), both of
> which dereference the pointer, see

Exactly, but insert_vmap_area_augement() accepts 'va', not 'lva',
but in your variant 'va' is already freed (see type == FL_FIT_TYPE
branch, on top of that function).  So that should be use-after-free.

--
Roman


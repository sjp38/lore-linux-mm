Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5F936B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 19:37:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r12so10841018pgu.9
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 16:37:36 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id l63si2893294plb.468.2017.11.14.16.37.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 16:37:36 -0800 (PST)
Subject: Re: [kernel-hardening] Re: [PATCH v6 03/11] mm, x86: Add support for
 eXclusive Page Frame Ownership (XPFO)
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-4-tycho@docker.com>
 <34454a32-72c2-c62e-546c-1837e05327e1@intel.com>
 <20170920223452.vam3egenc533rcta@smitten>
 <97475308-1f3d-ea91-5647-39231f3b40e5@intel.com>
 <20170921000901.v7zo4g5edhqqfabm@docker>
 <d1a35583-8225-2ab3-d9fa-273482615d09@intel.com>
 <20171110010907.qfkqhrbtdkt5y3hy@smitten>
 <7237ae6d-f8aa-085e-c144-9ed5583ec06b@intel.com>
 <2aa64bf6-fead-08cc-f4fe-bd353008ca59@intel.com>
 <20171115003358.r3bsukc3vlbikjef@cisco>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <c9516f27-ad4c-5b65-1611-f0c3604168bf@intel.com>
Date: Tue, 14 Nov 2017 16:37:34 -0800
MIME-Version: 1.0
In-Reply-To: <20171115003358.r3bsukc3vlbikjef@cisco>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tycho Andersen <tycho@tycho.ws>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, x86@kernel.org

On 11/14/2017 04:33 PM, Tycho Andersen wrote:
>>
>> void set_bh_page(struct buffer_head *bh,
>> ...
>> 	bh->b_data = page_address(page) + offset;
> Ah, yes. I guess there will be many bugs like this :). Anyway, I'll
> try to cook up a patch.

It won't catch all the bugs, but it might be handy to have a debugging
mode that records the location of the last user of page_address() and
friends.  That way, when we trip over an unmapped page, we have an
easier time finding the offender.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

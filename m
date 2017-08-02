Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 411B66B05D9
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 10:57:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id g71so6049747wmg.13
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 07:57:17 -0700 (PDT)
Received: from mail.univention.de (mail.univention.de. [82.198.197.8])
        by mx.google.com with ESMTPS id o19si5902852wra.335.2017.08.02.07.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 07:57:15 -0700 (PDT)
Subject: Re: [BUG] Slow SATA disk - waiting in balance_dirty_pages() on
 i686-pae.html
References: <2a526c85-0e27-7a5d-f606-66c74499352a@univention.de>
 <20170802122901.GB2529@dhcp22.suse.cz>
From: Philipp Hahn <hahn@univention.de>
Message-ID: <56b13e56-05c9-da59-d9a5-2a69c19e2cf4@univention.de>
Date: Wed, 2 Aug 2017 16:57:13 +0200
MIME-Version: 1.0
In-Reply-To: <20170802122901.GB2529@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Hello,

Am 02.08.2017 um 14:29 schrieb Michal Hocko:
> On Tue 01-08-17 12:32:40, Philipp Hahn wrote:
>> ;TL,DR: apt-get is blocked by balance_dirty_pages() with linux-{3,16
>> 4.2, 4.9}, but fast after reboot.
>>
>>
>> We still have several systems running 4.9.0-ucs104-686-pae. They have 16
>> GiB RAM and two disk:
> 
> I would strongly discourage you from using 32b system with so much
> memory. This will always bump into problems because of the inherent
> kernel/userspace split. Also I would bet that the problem you are seeing
> is the lack of lowmem memory which is considered for the dirty writers
> throttling unless you have vm.highmem_is_dirtyable is set to 1 which is
> not the case in your setup.

Thank you for the hint, I will give it a try.

Philipp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

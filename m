Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8ED1F6B05CF
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 08:29:04 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id y206so5637100wmd.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 05:29:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h37si4091945wrh.133.2017.08.02.05.29.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 05:29:03 -0700 (PDT)
Date: Wed, 2 Aug 2017 14:29:01 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [BUG] Slow SATA disk - waiting in balance_dirty_pages() on
 i686-pae.html
Message-ID: <20170802122901.GB2529@dhcp22.suse.cz>
References: <2a526c85-0e27-7a5d-f606-66c74499352a@univention.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2a526c85-0e27-7a5d-f606-66c74499352a@univention.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hahn <hahn@univention.de>
Cc: linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue 01-08-17 12:32:40, Philipp Hahn wrote:
> Hello,
> 
> ;TL,DR: apt-get is blocked by balance_dirty_pages() with linux-{3,16
> 4.2, 4.9}, but fast after reboot.
> 
> 
> We still have several systems running 4.9.0-ucs104-686-pae. They have 16
> GiB RAM and two disk:

I would strongly discourage you from using 32b system with so much
memory. This will always bump into problems because of the inherent
kernel/userspace split. Also I would bet that the problem you are seeing
is the lack of lowmem memory which is considered for the dirty writers
throttling unless you have vm.highmem_is_dirtyable is set to 1 which is
not the case in your setup.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id DA03A6B0006
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 14:39:00 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f4-v6so2412004pff.2
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 11:39:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i191-v6si20868990pge.545.2018.10.09.11.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 11:38:59 -0700 (PDT)
Date: Tue, 9 Oct 2018 20:38:54 +0200
From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [PATCH] mm: Preserve _PAGE_DEVMAP across mprotect() calls
Message-ID: <20181009183854.GB4783@linux-x5ow.site>
References: <20181009101917.32497-1-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181009101917.32497-1-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org, linux-nvdimm@lists.01.org

Looks good,
Reviewed-by: Johannes Thumshirn <jthumshirn@suse.de>
-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nurnberg
GF: Felix Imendorffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nurnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850

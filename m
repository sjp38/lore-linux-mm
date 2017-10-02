Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C583B6B0033
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 07:12:39 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z29so2352793qkg.3
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 04:12:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e10si945988qkj.77.2017.10.02.04.12.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 04:12:39 -0700 (PDT)
Date: Mon, 2 Oct 2017 13:12:31 +0200
From: Karel Zak <kzak@redhat.com>
Subject: Re: [PATCH 0/3] lsmem/chmem: add memory zone awareness
Message-ID: <20171002111231.z4ibknsg2gmvx53y@ws.net.home>
References: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170927174446.20459-1-gerald.schaefer@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: util-linux@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, linux-mm <linux-mm@kvack.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andre Wild <wild@linux.vnet.ibm.com>

On Wed, Sep 27, 2017 at 07:44:43PM +0200, Gerald Schaefer wrote:
> These patches are against lsmem/chmem in util-linux, they add support
> for listing and changing memory zone allocation.
> 
> Added Michal Hocko and linux-mm on cc, to raise general awareness for
> the lsmem/chmem tools, and the new memory zone functionality in
> particular. I think this can be quite useful for memory hotplug kernel
> development, and if not, sorry for the noise.

Seems good.

I'll merge it (probably with some minor changes:-) after v2.31
release. Thanks!

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

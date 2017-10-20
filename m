Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 815FC6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 06:45:20 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id v9so10704107oif.15
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 03:45:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i45si293150ote.51.2017.10.20.03.45.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 03:45:19 -0700 (PDT)
Date: Fri, 20 Oct 2017 12:45:14 +0200
From: Karel Zak <kzak@redhat.com>
Subject: Re: [PATCH 0/3] lsmem/chmem: add memory zone awareness
Message-ID: <20171020104514.z6bsu5vx5hgh46v5@ws.net.home>
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
> 
> Andre Wild (1):
>   lsmem/chmem: add memory zone awareness to bash-completion
> 
> Gerald Schaefer (2):
>   lsmem/chmem: add memory zone awareness
>   tests/lsmem: update lsmem test with ZONES column

Merged to the master branch.

I have added a new --split=<list> command line option to the lsmem.

It allows to control the way how lsmem merges memory blocks to the
ranges. The default is to use differences in STATE,REMOVABLE,NODE and
ZONES attributes. The ranges are no more affected by --output, it
means commands like

    lsmem --output=RANGE
    lsmem --output=RANGE,ZONES

returns the same memory ranges. You have to use --split to define your
policy:

    lsmem --split=REMOVABLE,STATE

will create the ranges according to REMOVABLE and STATE attributes.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

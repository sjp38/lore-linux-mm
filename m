Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 512BE6B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 14:21:52 -0400 (EDT)
Received: by widdi4 with SMTP id di4so83888268wid.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 11:21:51 -0700 (PDT)
Received: from lb3-smtp-cloud3.xs4all.net (lb3-smtp-cloud3.xs4all.net. [194.109.24.30])
        by mx.google.com with ESMTPS id w7si15258555wix.97.2015.04.13.11.21.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 11:21:50 -0700 (PDT)
Message-ID: <1428949307.3868.1.camel@x220>
Subject: Re: [PATCH 10/14] x86: mm: Enable deferred memory initialisation on
 x86-64
From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 13 Apr 2015 20:21:47 +0200
In-Reply-To: <1428920226-18147-11-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
	 <1428920226-18147-11-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2015-04-13 at 11:17 +0100, Mel Gorman wrote:
> --- a/mm/Kconfig
> +++ b/mm/Kconfig

> +# For architectures that was to support deferred memory initialisation

s/was/want/?

> +config ARCH_SUPPORTS_DEFERRED_MEM_INIT
> +	bool

Thanks,


Paul Bolle

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

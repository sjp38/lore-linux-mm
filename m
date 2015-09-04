Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D69306B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 11:22:13 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so21168110wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 08:22:13 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fj9si5064351wib.65.2015.09.04.08.22.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 08:22:12 -0700 (PDT)
Subject: Re: [PATCHv2] zswap: update docs for runtime-changeable attributes
References: <CALZtONB9LaMhYZNk7_aHp3iGigHLAmZ1uQLSKEni94RNOAKUSg@mail.gmail.com>
 <1440437595-10518-1-git-send-email-ddstreet@ieee.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E9B721.1020801@suse.cz>
Date: Fri, 4 Sep 2015 17:22:09 +0200
MIME-Version: 1.0
In-Reply-To: <1440437595-10518-1-git-send-email-ddstreet@ieee.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>, Jonathan Corbet <corbet@lwn.net>, Seth Jennings <sjennings@variantweb.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 08/24/2015 07:33 PM, Dan Streetman wrote:
> Change the Documentation/vm/zswap.txt doc to indicate that the "zpool"
> and "compressor" params are now changeable at runtime.
> 
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

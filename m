Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 37C756B0032
	for <linux-mm@kvack.org>; Wed,  8 Apr 2015 15:29:15 -0400 (EDT)
Received: by wiaa2 with SMTP id a2so71387735wia.0
        for <linux-mm@kvack.org>; Wed, 08 Apr 2015 12:29:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2si20268187wij.118.2015.04.08.12.29.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Apr 2015 12:29:13 -0700 (PDT)
Message-ID: <1428521343.11099.4.camel@stgolabs.net>
Subject: Re: HugePages_Rsvd leak
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Wed, 08 Apr 2015 12:29:03 -0700
In-Reply-To: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
References: <20150408161539.GA29546@sbohrermbp13-local.rgmadvisors.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2015-04-08 at 11:15 -0500, Shawn Bohrer wrote:
> AnonHugePages:    241664 kB
> HugePages_Total:     512
> HugePages_Free:      512
> HugePages_Rsvd:      384
> HugePages_Surp:        0
> Hugepagesize:       2048 kB
> 
> So here I have 384 pages reserved and I can't find anything that is
> using them. 

The output clearly shows all available hugepages are free, Why are you
assuming that reserved implies allocated/in use? This is not true,
please read one of the millions of docs out there -- you can start with:
https://www.kernel.org/doc/Documentation/vm/hugetlbpage.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

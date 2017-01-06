Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 974926B0038
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 19:00:49 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so1092367524pgi.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 16:00:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t6si77509661pfa.280.2017.01.05.16.00.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 16:00:44 -0800 (PST)
Date: Thu, 5 Jan 2017 16:02:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [next PATCH v4 0/3] Page fragment updates
Message-Id: <20170105160202.baa14f400bfd906466a915db@linux-foundation.org>
In-Reply-To: <20170104023620.13451.80691.stgit@localhost.localdomain>
References: <20170104023620.13451.80691.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 03 Jan 2017 18:38:48 -0800 Alexander Duyck <alexander.duyck@gmail.com> wrote:

> This patch series takes care of a few cleanups for the page fragments API.
> 
> First we do some renames so that things are much more consistent.  First we
> move the page_frag_ portion of the name to the front of the functions
> names.  Secondly we split out the cache specific functions from the other
> page fragment functions by adding the word "cache" to the name.
> 
> Finally I added a bit of documentation that will hopefully help to explain
> some of this.  I plan to revisit this later as we get things more ironed
> out in the near future with the changes planned for the DMA setup to
> support eXpress Data Path.
> 
> ---
> 
> v2: Fixed a comparison between a void* and 0 due to copy/paste from free_pages
> v3: Updated first rename patch so that it is just a rename and doesn't impact
>     the actual functionality to avoid performance regression.
> v4: Fix mangling that occured due to a bad merge fix when patches 1 and 2
>     were swapped and then swapped back.
> 
> I'm submitting this to Intel Wired Lan and Jeff Kirsher's "next-queue" for
> acceptance as I have a series of other patches for igb that are blocked by
> by these patches since I had to rename the functionality fo draining extra
> references.
> 
> This series was going to be accepted for mmotm back when it was v1, however
> since then I found a few minor issues that needed to be fixed.
> 
> I am hoping to get an Acked-by from Andrew Morton for these patches and
> then have them submitted to David Miller as he has said he will accept them
> if I get the Acked-by.  In the meantime if these can be applied to
> next-queue while waiting on that Acked-by then I can submit the other
> patches for igb and ixgbe for testing.

The patches look fine.  How about I just scoot them straight into
mainline next week?  I do that occasionally, just to simplify ongoing
development and these patches are safe enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

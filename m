Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 69C426B000A
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 10:46:43 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d40-v6so15176386pla.14
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 07:46:43 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id t29-v6si14467126pgn.442.2018.10.07.07.46.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 07:46:42 -0700 (PDT)
Date: Sun, 7 Oct 2018 08:46:40 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 2/2] docs/vm: split memory hotplug notifier description
 to Documentation/core-api
Message-ID: <20181007084640.76cd08c8@lwn.net>
In-Reply-To: <1538691061-31289-3-git-send-email-rppt@linux.vnet.ibm.com>
References: <1538691061-31289-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1538691061-31289-3-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: linux-doc@vger.kernel.org, linux-mm@kvack.org

On Fri,  5 Oct 2018 01:11:01 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> The memory hotplug notifier description is about kernel internals rather
> than admin/user visible API. Place it appropriately.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

One little nit...

>  Documentation/admin-guide/mm/memory-hotplug.rst    | 83 ---------------------
>  Documentation/core-api/index.rst                   |  2 +
>  Documentation/core-api/memory-hotplug-notifier.rst | 84 ++++++++++++++++++++++
>  3 files changed, 86 insertions(+), 83 deletions(-)
>  create mode 100644 Documentation/core-api/memory-hotplug-notifier.rst
> 
> diff --git a/Documentation/admin-guide/mm/memory-hotplug.rst b/Documentation/admin-guide/mm/memory-hotplug.rst
> index a33090c..0b9c83e 100644
> --- a/Documentation/admin-guide/mm/memory-hotplug.rst
> +++ b/Documentation/admin-guide/mm/memory-hotplug.rst
> @@ -31,7 +31,6 @@ be changed often.
>      6.1 Memory offline and ZONE_MOVABLE
>      6.2. How to offline memory
>    7. Physical memory remove
> -  8. Memory hotplug event notifier
>    9. Future Work List

That leaves a gap in the numbering here.

In general, the best solution to this sort of issue is to take the TOC out
entirely and let Sphinx worry about generating it.  People tend not to
think about updating the TOC when they make changes elsewhere, so it often
goes out of sync with the rest of the document anyway.

I'll apply these, but please feel free to send a patch to fix this up.

Thanks,

jon

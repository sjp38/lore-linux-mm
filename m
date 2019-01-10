Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5F6768E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 17:52:46 -0500 (EST)
Received: by mail-vs1-f70.google.com with SMTP id v199so5305909vsc.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:52:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x1sor44587141vsn.12.2019.01.10.14.52.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 14:52:45 -0800 (PST)
Received: from mail-vs1-f52.google.com (mail-vs1-f52.google.com. [209.85.217.52])
        by smtp.gmail.com with ESMTPSA id b131sm31015270vkf.45.2019.01.10.14.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 14:52:43 -0800 (PST)
Received: by mail-vs1-f52.google.com with SMTP id x1so8059290vsc.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:52:42 -0800 (PST)
MIME-Version: 1.0
References: <154690326478.676627.103843791978176914.stgit@dwillia2-desk3.amr.corp.intel.com>
 <154690327057.676627.18166704439241470885.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190110105638.GJ28934@suse.de> <CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com>
In-Reply-To: <CAPcyv4gkSBW5Te0RZLrkxzufyVq56-7pHu__YfffBiWhoqg7Yw@mail.gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Jan 2019 14:52:29 -0800
Message-ID: <CAGXu5jL1sivv70_Uahbg=cMZP2UM=eYBn4u8nx3NU5ayzHf28g@mail.gmail.com>
Subject: Re: [PATCH v7 1/3] mm: Shuffle initial free memory to improve
 memory-side-cache utilization
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jan 10, 2019 at 1:29 PM Dan Williams <dan.j.williams@intel.com> wrote:
> Note that higher order merging is not a current concern since the
> implementation is already randomizing on MAX_ORDER sized pages. Since
> memory side caches are so large there's no worry about a 4MB
> randomization boundary.
>
> However, for the (unproven) security use case where folks want to
> experiment with randomizing on smaller granularity, they should be
> wary of this (/me nudges Kees).

Yup. And I think this is well noted in the Kconfig help already. I
view this as slightly more fine grain randomization than we get from
just effectively the base address randomization that
CONFIG_RANDOMIZE_MEMORY performs.

I remain a fan of this series. :)

-- 
Kees Cook

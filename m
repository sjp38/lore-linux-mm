Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 457226B0003
	for <linux-mm@kvack.org>; Mon, 21 May 2018 18:12:36 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id bd7-v6so10837591plb.20
        for <linux-mm@kvack.org>; Mon, 21 May 2018 15:12:36 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id ba9-v6si15142653plb.110.2018.05.21.15.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 May 2018 15:12:34 -0700 (PDT)
Subject: Re: Why do we let munmap fail?
References: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <aacd607f-4a0d-2b0a-d8d9-b57c686d24fc@intel.com>
Date: Mon, 21 May 2018 15:12:32 -0700
MIME-Version: 1.0
In-Reply-To: <CAKOZuetOD6MkGPVvYFLj5RXh200FaDyu3sQqZviVRhTFFS3fjA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Colascione <dancol@google.com>, linux-mm@kvack.org
Cc: Tim Murray <timmurray@google.com>, Minchan Kim <minchan@kernel.org>

On 05/21/2018 03:07 PM, Daniel Colascione wrote:
> Now let's return to max_map_count itself: what is it supposed to achieve?
> If we want to limit application kernel memory resource consumption, let's
> limit application kernel memory resource consumption, accounting for it on
> a byte basis the same way we account for other kernel objects allocated on
> behalf of userspace. Why should we have a separate cap just for the VMA
> count?

VMAs consume kernel memory and we can't reclaim them.  That's what it
boils down to.

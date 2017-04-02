Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5B06B0038
	for <linux-mm@kvack.org>; Sun,  2 Apr 2017 16:34:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id p20so122809154pgd.21
        for <linux-mm@kvack.org>; Sun, 02 Apr 2017 13:34:22 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id w82si11943919pfi.384.2017.04.02.13.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 02 Apr 2017 13:34:21 -0700 (PDT)
Date: Sun, 2 Apr 2017 14:34:18 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 0/9] convert genericirq.tmpl and kernel-api.tmpl to
 DocBook
Message-ID: <20170402143418.3de75239@lwn.net>
In-Reply-To: <cover.1490904090.git.mchehab@s-opensource.com>
References: <cover.1490904090.git.mchehab@s-opensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mauro Carvalho Chehab <mchehab@s-opensource.com>
Cc: Linux Media Mailing List <linux-media@vger.kernel.org>, Linux Doc Mailing List <linux-doc@vger.kernel.org>, Mauro Carvalho Chehab <mchehab@infradead.org>, Noam Camus <noamca@mellanox.com>, James Morris <james.l.morris@oracle.com>, zijun_hu <zijun_hu@htc.com>, Markus Heiser <markus.heiser@darmarit.de>, linux-clk@vger.kernel.org, Jani Nikula <jani.nikula@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Nicholas Piggin <npiggin@gmail.com>, Russell King <linux@armlinux.org.uk>, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ingo Molnar <mingo@kernel.org>, Bjorn Helgaas <bhelgaas@google.com>, "Serge E. Hallyn" <serge@hallyn.com>, Michal Hocko <mhocko@suse.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Chris Wilson <chris@chris-wilson.co.uk>, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Silvio Fricke <silvio.fricke@gmail.com>, Takashi Iwai <tiwai@suse.de>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Jan Kara <jack@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-pci@vger.kernel.org, Matt Fleming <matt@codeblueprint.co.uk>, Johannes Weiner <hannes@cmpxchg.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Andy Lutomirski <luto@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Alexey Dobriyan <adobriyan@gmail.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Thu, 30 Mar 2017 17:11:27 -0300
Mauro Carvalho Chehab <mchehab@s-opensource.com> wrote:

> This series converts just two documents, adding them to the
> core-api.rst book. It addresses the errors/warnings that popup
> after the conversion.
> 
> I had to add two fixes to scripts/kernel-doc, in order to solve
> some of the issues.

I've applied the set, including the add-on to move some stuff to
driver-api - thanks.

For whatever reason, I had a hard time applying a few of these; "git am"
would tell me this:

> Applying: docs-rst: core_api: move driver-specific stuff to drivers_api
> fatal: sha1 information is lacking or useless (Documentation/driver-api/index.rst).
> Patch failed at 0001 docs-rst: core_api: move driver-specific stuff to drivers_api
> The copy of the patch that failed is found in: .git/rebase-apply/patch

I was able to get around this, but it took some hand work.  How are you
generating these?

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

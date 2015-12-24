Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id A5ADD82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 14:58:44 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id l126so188174459wml.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 11:58:44 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id b133si41075710wmd.90.2015.12.24.11.58.43
        for <linux-mm@kvack.org>;
        Thu, 24 Dec 2015 11:58:43 -0800 (PST)
Date: Thu, 24 Dec 2015 20:58:37 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
Message-ID: <20151224195837.GE4128@pd.tnic>
References: <1450283759.20148.11.camel@hpe.com>
 <20151216174523.GH29775@pd.tnic>
 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
 <20151216181712.GJ29775@pd.tnic>
 <1450302758.20148.75.camel@hpe.com>
 <20151222113422.GE3728@pd.tnic>
 <1450814672.10450.83.camel@hpe.com>
 <20151223142349.GG30213@pd.tnic>
 <1450923815.19330.4.camel@hpe.com>
 <1450976937.19330.11.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1450976937.19330.11.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Thu, Dec 24, 2015 at 10:08:57AM -0700, Toshi Kani wrote:
> As for checkpatch, I noticed that commit 9c0ece069b3 removed "feature
> -removal.txt" file, and checkpatch removed this check in commit
> 78e3f1f01d2.  checkpatch does not have such check since then.  So, I am
> inclined not to add this check back to checkpatch.

I didn't mean that.

Rather, something along the lines of, for example,
the DEFINE_PCI_DEVICE_TABLE matching but match those
resource matching functions using the strings, i.e.,
"(walk_iomem_res|find_next_iomem_res|region_intersects)" or so and
warn when new code uses them and that it should rather use the new
desc-matching variants.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

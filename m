Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id EB2226B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 17:33:18 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p63so94026497wmp.1
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:33:18 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id b130si34977706wmc.76.2016.02.11.14.33.17
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 14:33:18 -0800 (PST)
Date: Thu, 11 Feb 2016 23:33:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v11 0/4] Machine check recovery when kernel accesses
 poison
Message-ID: <20160211223312.GK5565@pd.tnic>
References: <cover.1455225826.git.tony.luck@intel.com>
 <20160211220222.GJ5565@pd.tnic>
 <3908561D78D1C84285E8C5FCA982C28F39FD8BFB@ORSMSX114.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F39FD8BFB@ORSMSX114.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "Williams, Dan J" <dan.j.williams@intel.com>, "elliott@hpe.com" <elliott@hpe.com>, Brian Gerst <brgerst@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "x86@kernel.org" <x86@kernel.org>

On Thu, Feb 11, 2016 at 10:16:56PM +0000, Luck, Tony wrote:
> > That's some changelog, I tell ya. Well, it took us long enough so for all 4:
> 
> I'll see if Peter Jackson wants to turn it into a series of movies.

LOL. A passing title might be "The Fellowship of the MCA"!

:-)

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v3 1/3] resource: Add @flags to region_intersects()
Date: Thu, 3 Dec 2015 19:40:51 +0100
Message-ID: <20151203184051.GE3213@pd.tnic>
References: <1448404418-28800-1-git-send-email-toshi.kani@hpe.com>
 <1448404418-28800-2-git-send-email-toshi.kani@hpe.com>
 <20151201135000.GB4341@pd.tnic>
 <CAPcyv4g2n9yTWye2aVvKMP0X7mrm_NLKmGd5WBO2SesTj77gbg@mail.gmail.com>
 <20151201171322.GD4341@pd.tnic>
 <CA+55aFw22JD8W2cy3w=5VcU9-ENXSP9utmhGB2NeiDVqwpnUSw@mail.gmail.com>
 <1449168859.9855.54.camel@hpe.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-acpi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1449168859.9855.54.camel@hpe.com>
Sender: linux-acpi-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hpe.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux ACPI <linux-acpi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Dec 03, 2015 at 11:54:19AM -0700, Toshi Kani wrote:
> Adding a new type for regular memory will require inspecting the codes
> using IORESOURCE_MEM currently, and modify them to use the new type if
> their target ranges are regular memory.  There are many references to this
> type across multiple architectures and drivers, which make this inspection
> and testing challenging.

What's wrong with adding a new type_flags to struct resource and not
touching IORESOURCE_* at all?

They'll be called something like RES_TYPE_RAM, _PMEM, _SYSMEM...

Or would that confuse more...?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

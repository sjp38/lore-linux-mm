From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Date: Mon, 18 May 2015 22:01:14 +0200
Message-ID: <20150518200114.GE23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
 <20150518133348.GA23618@pd.tnic>
 <1431969759.19889.5.camel@misato.fc.hp.com>
 <20150518190150.GC23618@pd.tnic>
 <1431977519.20569.15.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431977519.20569.15.camel@misato.fc.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com
List-Id: linux-mm.kvack.org

On Mon, May 18, 2015 at 01:31:59PM -0600, Toshi Kani wrote:
> Well, #2 and #3 are independent. That is, uniform can be set regardless

Not #2 and #3 above - the original #2 and #3 ones. I've written them out
detailed to show what I mean.

> The caller is responsible for verifying the conditions that are safe to
> create huge page.

How is the caller ever going to be able to do anything about it?

Regardless, I'd prefer to not duplicate comments and rather put a short
sentence pointing the reader to the comments over mtrr_type_lookup()
where this all is being explained in detail.

I'll fix it up.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

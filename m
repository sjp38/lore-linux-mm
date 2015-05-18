From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 6/6] mtrr, mm, x86: Enhance MTRR checks for KVA huge
 page mapping
Date: Mon, 18 May 2015 22:51:24 +0200
Message-ID: <20150518205123.GI23618@pd.tnic>
References: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
 <1431714237-880-7-git-send-email-toshi.kani@hp.com>
 <20150518133348.GA23618@pd.tnic>
 <1431969759.19889.5.camel@misato.fc.hp.com>
 <20150518190150.GC23618@pd.tnic>
 <1431977519.20569.15.camel@misato.fc.hp.com>
 <20150518200114.GE23618@pd.tnic>
 <1431980468.21019.11.camel@misato.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431980468.21019.11.camel@misato.fc.hp.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Toshi Kani <toshi.kani@hp.com>
Cc: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com
List-Id: linux-mm.kvack.org

On Mon, May 18, 2015 at 02:21:08PM -0600, Toshi Kani wrote:
> The caller is the one who makes the condition checks necessary to create
> a huge page mapping.

How? It would go and change MTRRs configuration and ranges and their
memory types so that a huge mapping succeeds?

Or go and try a different range?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

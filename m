Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id B2DD56B0038
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 18:38:44 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so96352621pab.0
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 15:38:44 -0800 (PST)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id pi4si22297609pac.212.2015.12.04.15.38.42
        for <linux-mm@kvack.org>;
        Fri, 04 Dec 2015 15:38:44 -0800 (PST)
Subject: Re: [PATCH 00/34] x86: Memory Protection Keys (v5)
References: <20151204011424.8A36E365@viggo.jf.intel.com>
 <CALCETrXwVb99hAvqR2o54aPwtpr8oubROtiRt45SiYRfUTAxCw@mail.gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56622401.20001@sr71.net>
Date: Fri, 4 Dec 2015 15:38:41 -0800
MIME-Version: 1.0
In-Reply-To: <CALCETrXwVb99hAvqR2o54aPwtpr8oubROtiRt45SiYRfUTAxCw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, X86 ML <x86@kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-arch <linux-arch@vger.kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 12/04/2015 03:31 PM, Andy Lutomirski wrote:
> On Thu, Dec 3, 2015 at 5:14 PM, Dave Hansen <dave@sr71.net> wrote:
>> Memory Protection Keys for User pages is a CPU feature which will
>> first appear on Skylake Servers, but will also be supported on
>> future non-server parts.  It provides a mechanism for enforcing
>> page-based protections, but without requiring modification of the
>> page tables when an application changes protection domains.  See
>> the Documentation/ patch for more details.
> 
> What, if anything, happened to the signal handling parts?

Patches 12 and 13 contain most of it:

	x86, pkeys: fill in pkey field in siginfo
	signals, pkeys: notify userspace about protection key faults	

I decided to just not try to preserve the pkey_get/set() semantics
across entering and returning from signals, fwiw.

> Also, do you have a git tree for this somewhere?  I can't actually
> enable it (my laptop, while very shiny, is not a Skylake server), but
> I can poke around a bit.

http://git.kernel.org/cgit/linux/kernel/git/daveh/x86-pkeys.git/

Thanks for taking a look!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

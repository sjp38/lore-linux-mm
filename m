Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4FF6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 12:07:24 -0400 (EDT)
Received: by wgme6 with SMTP id e6so118631499wgm.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:07:23 -0700 (PDT)
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id pe2si25460450wjb.151.2015.06.01.09.07.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jun 2015 09:07:22 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so118809164wgb.3
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 09:07:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <556C4593.5090600@plexistor.com>
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com>
	<20150530185940.32590.37804.stgit@dwillia2-desk3.amr.corp.intel.com>
	<556C4477.8090803@plexistor.com>
	<556C4593.5090600@plexistor.com>
Date: Mon, 1 Jun 2015 09:07:21 -0700
Message-ID: <CAPcyv4h2gibrb6bEVjEQuSqDM+qS5L3gqUfU7AEH0PH7khTwDw@mail.gmail.com>
Subject: Re: [PATCH v2 4/4] arch, x86: cache management apis for persistent memory
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Juergen Gross <jgross@suse.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Luis Rodriguez <mcgrof@suse.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Stefan Bader <stefan.bader@canonical.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, geert@linux-m68k.org, Henrique de Moraes Holschuh <hmh@hmh.eng.br>, Tejun Heo <tj@kernel.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 1, 2015 at 4:44 AM, Boaz Harrosh <boaz@plexistor.com> wrote:
> Forgot one thing
>
> On 06/01/2015 02:39 PM, Boaz Harrosh wrote:
>>> +static inline void persistent_copy(void *dst, const void *src, size_t n)
>
> Could we please make this
> memcpy_persistent
>
> Same as:
> copy_from_user_nocache
>
> The generic name of what it does first then the special override.
> copy_from_user_XXX is same as copy_from_user but with XXX applied
>
> Same here exactly as memcpy_ but with persistent applied.

Ok, makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

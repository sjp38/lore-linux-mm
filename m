Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 184636B0037
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 11:27:59 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n15so4853552wiw.2
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 08:27:58 -0700 (PDT)
Received: from mail.emea.novell.com (mail.emea.novell.com. [130.57.118.101])
        by mx.google.com with ESMTPS id s8si22162199wif.65.2014.06.02.08.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Jun 2014 08:27:57 -0700 (PDT)
Message-Id: <538CB4180200007800016F7F@mail.emea.novell.com>
Date: Mon, 02 Jun 2014 16:27:52 +0100
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [PATCH] improve __GFP_COLD/__GFP_ZERO interaction
References: <538CAA520200007800016E87@mail.emea.novell.com>
 <20140602151629.GA8160@node.dhcp.inet.fi>
In-Reply-To: <20140602151629.GA8160@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: David Vrabel <david.vrabel@citrix.com>, mingo@elte.hu, linux-mm@kvack.org, tglx@linutronix.de, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, hpa@zytor.com

>>> On 02.06.14 at 17:16, <kirill@shutemov.name> wrote:
> On Mon, Jun 02, 2014 at 03:46:10PM +0100, Jan Beulich wrote:
>> For cold page allocations using the normal clear_highpage() mechanism
>> may be inefficient on certain architectures, namely due to needlessly
>> replacing a good part of the data cache contents. Introduce an arch-
>> overridable clear_cold_highpage() (using streaming non-temporal stores
>> on x86, where an override gets implemented right away) to make use of
>> in this specific case.
>>=20
>> Leverage the impovement in the Xen balloon driver, eliminating the
>> explicit scrub_page() function.
>=20
> Any benchmark data?
>=20
> I've tried non-temporal stores to clear huge pages, but it didn't helped
> much. I believe it can vary between micro-architectures, but we need
> numbers. I've played with Westmere that time.

It's not at all clear to me what to measure here - after all this isn't
about improving the page clearing latency or throughput, but about
avoiding to disturb other operations.

Jan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

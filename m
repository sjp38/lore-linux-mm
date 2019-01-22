Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52EFA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:52:38 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a23so17876005pfo.2
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:52:38 -0800 (PST)
Received: from prv1-mh.provo.novell.com (prv1-mh.provo.novell.com. [137.65.248.33])
        by mx.google.com with ESMTPS id q2si16021899plh.261.2019.01.22.00.52.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:52:37 -0800 (PST)
Message-Id: <5C46D9D00200007800210007@prv1-mh.provo.novell.com>
Date: Tue, 22 Jan 2019 01:52:32 -0700
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [PATCH 2/2] x86/xen: dont add memory above max
 allowed allocation
References: <20190122080628.7238-1-jgross@suse.com>
 <20190122080628.7238-3-jgross@suse.com>
In-Reply-To: <20190122080628.7238-3-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: Borislav Petkov <bp@alien8.de>, Stefano Stabellini <sstabellini@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, linux-mm@kvack.org, tglx@linutronix.de, xen-devel <xen-devel@lists.xenproject.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, mingo@redhat.com, linux-kernel@vger.kernel.org, hpa@zytor.com

>>> On 22.01.19 at 09:06, <jgross@suse.com> wrote:
> Don't allow memory to be added above the allowed maximum allocation
> limit set by Xen.

This reads as if the hypervisor was imposing a limit here, but looking at
xen_get_max_pages(), xen_foreach_remap_area(), and
xen_count_remap_pages() I take it that it's a restriction enforced by
the Xen subsystem in Linux. Furthermore from the cover letter I imply
that the observed issue was on a Dom0, yet xen_get_max_pages()'s
use of XENMEM_maximum_reservation wouldn't impose any limit there
at all (without use of the hypervisor option "dom0_mem=3Dmax:..."),
would it?

Jan

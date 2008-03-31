Date: Mon, 31 Mar 2008 15:07:39 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 8/8] x86_64: V2 Support for new UV apic
Message-ID: <20080331130739.GE14636@elte.hu>
References: <20080328191216.GA16455@sgi.com> <20080331020207.GA20605@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080331020207.GA20605@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: tglx@linutronix.de, yhlu.kernel@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Jack Steiner <steiner@sgi.com> wrote:

> Fix double-shift of apicid in previous patch.

> The code is clearly wrong.  I booted on an 8p AMD box and had no 
> problems. Apparently the kernel (at least basic booting) is not too 
> sensitive to incorrect apicids being returned. Most critical-to-boot 
> code must use apicids from the ACPI tables.

yeah - patch added. Thanks Yinghai for persisting on this.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

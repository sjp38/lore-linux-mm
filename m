Received: by rv-out-0910.google.com with SMTP id f1so738441rvb.26
        for <linux-mm@kvack.org>; Sun, 30 Mar 2008 19:13:43 -0700 (PDT)
Message-ID: <86802c440803301913n1cd4fe88v2374a8ba835153e@mail.gmail.com>
Date: Sun, 30 Mar 2008 19:13:42 -0700
From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: [PATCH 8/8] x86_64: Support for new UV apic
In-Reply-To: <20080331020613.GA20619@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080328191216.GA16455@sgi.com>
	 <86802c440803301622j2874ca56t51b52a54920a233b@mail.gmail.com>
	 <20080331020613.GA20619@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jack Steiner <steiner@sgi.com>
Cc: Andi Kleen <ak@suse.de>, mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 30, 2008 at 7:06 PM, Jack Steiner <steiner@sgi.com> wrote:
> > so this is "the new one of Friday"?
>
>  Yes, and it has the same bug although it is located
>  in a slightly different place.
>
>  A few minutes ago, I posted a patch to delete the extra lines.
>
>
>
>  > Did you test it on non UV_X2APIC box?
>
>  The code is clearly wrong.  I booted on an 8p AMD box and
>  had no problems. Apparently the kernel (at least basic booting) is
>  not too sensitive to incorrect apicids being returned. Most
>  critical-to-boot code must use apicids from the ACPI tables.
>  However, the bug does affect numa node assignment. And probably
>  other places, too.

please consider one global get_apic_id() and bad_apicid to replace
GET_APIC_ID and BAD_APICID at this point.

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE829C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:30:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8482F20882
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:30:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8482F20882
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CF526B0269; Thu,  4 Apr 2019 12:30:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47F046B026A; Thu,  4 Apr 2019 12:30:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3216C6B026B; Thu,  4 Apr 2019 12:30:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id D53296B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:30:00 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id t10so2293091wrp.3
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:30:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=rdu8TEDS1cDwlpdawiM/OWJMOY3nxO1tCZ1slcoIjc8=;
        b=G8bIYtr5pNNpZ5zVfc7ipbEolv+43Rzw2xMuSwlnChxWSzuwAoj9SUbrmQewCqNcxs
         v8i1/rUPnPDnpvYJ+YcMfzeAwoguo63ISyG4qwEVmbAgalbvzszYvb/NKIJv6ZGdD233
         zjRJ2n5w4nRdlJ4nVOg5r07fzYyhsCVgcVrxAZVl/DnIBh+FWOC/SAP5D7ucHW45iXai
         Kr3v/zzrUo9X48v1zxcSNcMms+aK+7jhxU86eA/aZ3n4U6iOFmhR45q7/9AIEj+wXZVe
         +IXUp8RGAh1seY6ijZWR3IVVfDGJ7s/idE5E+XYVXT59tW8le0cXoyGJChCnf/WnATyM
         1gTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAXgz6+oAsaJwVXlv3eVjDvxHdWIg4v2BFHIDddWwr7RS2OBX0HP
	R8HdMphl47IrmnZtI9qA1vL07nM17/WH+0ptzlLdtm4DAqThrg4gympra9cbE+Fs0A2NEoeNgk+
	II0Xanvcb+TA5diPDBBksq8L4tJ5tDhn/e/jOZs7vV72LJF9qlS9UirtzXA17k4G1hA==
X-Received: by 2002:a1c:6455:: with SMTP id y82mr3270685wmb.104.1554395400405;
        Thu, 04 Apr 2019 09:30:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfmo4AY50YLS4gezlKMuLdVLhOXTafvtFIZkovhg0QsNxFmD3NMbtDGlMDh3PcxTsox33T
X-Received: by 2002:a1c:6455:: with SMTP id y82mr3270639wmb.104.1554395399644;
        Thu, 04 Apr 2019 09:29:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554395399; cv=none;
        d=google.com; s=arc-20160816;
        b=Oc32YSR4Z0vSOq2tEXf/7L41twWadF3PcJxxGN+MsOEJD2JG/2ddVVBt17arePXIM6
         kGYUrWEfVHwCBeqUjN8ZXt3fHDm/1Eki7DhlfeLFVQWrVBh8gOKi+EwtQQSXphMgeVeM
         6xLlWRGNqNgp6dL0D0cV4megPXbW2BkxjPMtpkz6AyUhKcrspJbyoIdspS+5qDIECSrH
         m3qunjRe4UbhDlytGeZZlv8wCaEW1tZ3vDMlxi1C6LUg0vZlnIByxKHBMEpoFyL8HYf7
         EyI3Gz39FVROZzIlM/4RFU1vFHrCcGsQ2vzblpa44NvOHdx+kColkPo6hsUnKkzMx1ic
         RCbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=rdu8TEDS1cDwlpdawiM/OWJMOY3nxO1tCZ1slcoIjc8=;
        b=ce++P3Lq2+axcgIrtUb/EuvZ8MTecUEJ4r3ogWlNbJzuegoRHOcmTAwyqzk5hHnvdG
         nVclxSI0iBNYa6Cb1LWeSi65Y60yLQJLxuXbtK6kr3v75i+mQ3W3VTZ7mwsD3IN6GHOh
         rGaWdgl4+gPico34VIgzY+NlroL2A4cGXEPtKZ+ZNdb+iHWkmzPn+y6AMsOIQ0FWJO0Z
         aQgGxdFN48DhXVt8Jmf1nPtXnDoRnYr4UwI6PCzA3e0VXTN901sYfjoYcFI73OStOCUl
         S+7rkfI3ajsNYMmv3VMumW3zA6iQJMNTj3umTsUardghK266Ql011nwwlZyf8Y5xKhdx
         PuXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id a10si12035327wme.136.2019.04.04.09.29.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 04 Apr 2019 09:29:59 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) client-ip=2a01:7a0:2:106d:700::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a01:7a0:2:106d:700::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from p5492e2fc.dip0.t-ipconnect.de ([84.146.226.252] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hC5EV-0005jm-4g; Thu, 04 Apr 2019 18:28:55 +0200
Date: Thu, 4 Apr 2019 18:28:53 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Tycho Andersen <tycho@tycho.ws>
cc: Andy Lutomirski <luto@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, 
    Juerg Haefliger <juergh@gmail.com>, jsteckli@amazon.de, 
    Andi Kleen <ak@linux.intel.com>, liran.alon@oracle.com, 
    Kees Cook <keescook@google.com>, 
    Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, 
    deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, 
    Tyler Hicks <tyhicks@canonical.com>, 
    "Woodhouse, David" <dwmw@amazon.co.uk>, 
    Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, 
    Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, 
    Joao Martins <joao.m.martins@oracle.com>, 
    Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, 
    John Haxby <john.haxby@oracle.com>, 
    "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
    Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, 
    Laura Abbott <labbott@redhat.com>, Dave Hansen <dave.hansen@intel.com>, 
    Peter Zijlstra <peterz@infradead.org>, Aaron Lu <aaron.lu@intel.com>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    alexander.h.duyck@linux.intel.com, Amir Goldstein <amir73il@gmail.com>, 
    Andrey Konovalov <andreyknvl@google.com>, aneesh.kumar@linux.ibm.com, 
    anthony.yznaga@oracle.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
    Arnd Bergmann <arnd@arndb.de>, arunks@codeaurora.org, 
    Ben Hutchings <ben@decadent.org.uk>, 
    Sebastian Andrzej Siewior <bigeasy@linutronix.de>, 
    Borislav Petkov <bp@alien8.de>, brgl@bgdev.pl, 
    Catalin Marinas <catalin.marinas@arm.com>, 
    Jonathan Corbet <corbet@lwn.net>, cpandya@codeaurora.org, 
    Daniel Vetter <daniel.vetter@ffwll.ch>, 
    Dan Williams <dan.j.williams@intel.com>, 
    Greg KH <gregkh@linuxfoundation.org>, Roman Gushchin <guro@fb.com>, 
    Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, James Morse <james.morse@arm.com>, 
    Jann Horn <jannh@google.com>, Juergen Gross <jgross@suse.com>, 
    Jiri Kosina <jkosina@suse.cz>, James Morris <jmorris@namei.org>, 
    Joe Perches <joe@perches.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
    Joerg Roedel <jroedel@suse.de>, Keith Busch <keith.busch@intel.com>, 
    Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, 
    Logan Gunthorpe <logang@deltatee.com>, marco.antonio.780@gmail.com, 
    Mark Rutland <mark.rutland@arm.com>, 
    Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, 
    Michal Hocko <mhocko@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, 
    Ingo Molnar <mingo@redhat.com>, "Michael S. Tsirkin" <mst@redhat.com>, 
    Marek Szyprowski <m.szyprowski@samsung.com>, 
    Nicholas Piggin <npiggin@gmail.com>, osalvador@suse.de, 
    "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, 
    pavel.tatashin@microsoft.com, Randy Dunlap <rdunlap@infradead.org>, 
    richard.weiyang@gmail.com, "Serge E. Hallyn" <serge@hallyn.com>, 
    iommu@lists.linux-foundation.org, X86 ML <x86@kernel.org>, 
    linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, 
    "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
    LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
    LSM List <linux-security-module@vger.kernel.org>, 
    Khalid Aziz <khalid@gonehiking.org>
Subject: Re: [RFC PATCH v9 02/13] x86: always set IF before oopsing from page
 fault
In-Reply-To: <20190404154727.GA14030@cisco>
Message-ID: <alpine.DEB.2.21.1904041822320.1802@nanos.tec.linutronix.de>
References: <cover.1554248001.git.khalid.aziz@oracle.com> <e6c57f675e5b53d4de266412aa526b7660c47918.1554248002.git.khalid.aziz@oracle.com> <CALCETrXvwuwkVSJ+S5s7wTBkNNj3fRVxpx9BvsXWrT=3ZdRnCw@mail.gmail.com> <20190404013956.GA3365@cisco>
 <CALCETrVp37Xo3EMHkeedP1zxUMf9og=mceBa8c55e1F4G1DRSQ@mail.gmail.com> <20190404154727.GA14030@cisco>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019, Tycho Andersen wrote:
>  	leaq	-PTREGS_SIZE(%rax), %rsp
>  	UNWIND_HINT_FUNC sp_offset=PTREGS_SIZE
>  
> +	/*
> +	 * If we oopsed in an interrupt handler, interrupts may be off. Let's turn
> +	 * them back on before going back to "normal" code.
> +	 */
> +	sti

That breaks the paravirt muck and tracing/lockdep.

ENABLE_INTERRUPTS() is what you want plus TRACE_IRQ_ON to keep the tracer
and lockdep happy.

Thanks,

	tglx


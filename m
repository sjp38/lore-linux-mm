Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9DD746B02F4
	for <linux-mm@kvack.org>; Mon, 15 May 2017 10:12:27 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id q6so99393273pgn.12
        for <linux-mm@kvack.org>; Mon, 15 May 2017 07:12:27 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id a74si10763216pfl.231.2017.05.15.07.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 07:12:26 -0700 (PDT)
Date: Mon, 15 May 2017 17:11:19 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv5, REBASED 8/9] x86: Enable 5-level paging support
Message-ID: <20170515141118.wh45ham64unjk5y2@black.fi.intel.com>
References: <20170515121218.27610-1-kirill.shutemov@linux.intel.com>
 <20170515121218.27610-9-kirill.shutemov@linux.intel.com>
 <9af22de7-89f3-576a-f933-c4e593924091@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9af22de7-89f3-576a-f933-c4e593924091@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 15, 2017 at 02:31:00PM +0200, Juergen Gross wrote:
> > diff --git a/arch/x86/xen/Kconfig b/arch/x86/xen/Kconfig
> > index 027987638e98..12205e6dfa59 100644
> > --- a/arch/x86/xen/Kconfig
> > +++ b/arch/x86/xen/Kconfig
> > @@ -5,6 +5,7 @@
> >  config XEN
> >  	bool "Xen guest support"
> >  	depends on PARAVIRT
> > +	depends on !X86_5LEVEL
> 
> I'd rather put this under "config XEN_PV".

Makes sense.

----------------------8<----------------------------

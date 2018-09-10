Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D54A78E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 17:07:22 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id m3-v6so10528122plt.9
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 14:07:22 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v1-v6si18847577pfc.23.2018.09.10.14.07.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 14:07:21 -0700 (PDT)
Date: Tue, 11 Sep 2018 00:07:17 +0300
From: Jarkko Sakkinen <jarkko.sakkinen@intel.com>
Subject: Re: [RFC 09/12] mm: Restrict memory encryption to anonymous VMA's
Message-ID: <20180910210716.GB26766@intel.com>
References: <cover.1536356108.git.alison.schofield@intel.com>
 <f69e3d4f96504185054d951c7c85075ebf63e47a.1536356108.git.alison.schofield@intel.com>
 <ae0288d5205a5c431e9a6bf0c9e68beded45e84b.camel@intel.com>
 <84154fd2-7c27-0fd2-f339-15e144a5df49@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84154fd2-7c27-0fd2-f339-15e144a5df49@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "tglx@linutronix.de" <tglx@linutronix.de>, "Schofield, Alison" <alison.schofield@intel.com>, "dhowells@redhat.com" <dhowells@redhat.com>, "Shutemov, Kirill" <kirill.shutemov@intel.com>, "keyrings@vger.kernel.org" <keyrings@vger.kernel.org>, "jmorris@namei.org" <jmorris@namei.org>, "Huang, Kai" <kai.huang@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-security-module@vger.kernel.org" <linux-security-module@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "hpa@zytor.com" <hpa@zytor.com>, "mingo@redhat.com" <mingo@redhat.com>, "Nakajima, Jun" <jun.nakajima@intel.com>

On Mon, Sep 10, 2018 at 11:57:49AM -0700, Dave Hansen wrote:
> On 09/10/2018 11:21 AM, Sakkinen, Jarkko wrote:
> >> +/*
> >> + * Encrypted mprotect is only supported on anonymous mappings.
> >> + * All VMA's in the requested range must be anonymous. If this
> >> + * test fails on any single VMA, the entire mprotect request fails.
> >> + */
> > kdoc
> 
> kdoc what?  You want this comment in kdoc format?  Why?

If there is a header comment for a function anyway, why wouldn't you
put it to kdoc-format?

/Jarkko

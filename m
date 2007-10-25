Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l9PJx18o000633
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:59:01 -0700
Received: from nf-out-0910.google.com (nfde27.prod.google.com [10.48.131.27])
	by zps76.corp.google.com with ESMTP id l9PJwxbL012126
	for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:59:00 -0700
Received: by nf-out-0910.google.com with SMTP id e27so549588nfd
        for <linux-mm@kvack.org>; Thu, 25 Oct 2007 12:58:59 -0700 (PDT)
Message-ID: <d43160c70710251258m745c70a7t462cad964ffb2f9f@mail.gmail.com>
Date: Thu, 25 Oct 2007 15:58:59 -0400
From: "Ross Biro" <rossb@google.com>
Subject: Re: RFC/POC Make Page Tables Relocatable
In-Reply-To: <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com>
	 <1193330774.4039.136.camel@localhost>
	 <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com>
	 <1193335725.24087.19.camel@localhost>
	 <d43160c70710251144t172cfd1exef99e0d53fb9be73@mail.gmail.com>
	 <1193340182.24087.54.camel@localhost>
	 <d43160c70710251253j2f4e640uc0ccc0432738f55c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On 10/25/07, Ross Biro <rossb@google.com> wrote:
> On 10/25/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> > With the pagetable page you can go examine ptes.  From the ptes, you can
> > get the 'struct page' for the mapped page.  From there, you can get the
>
> Definitely worth considering.

Now I remember.  At least in the slab allocator, the relocation code
must hold an important spinlock while the relocation occurs.  Maybe I
can get around that, but maybe not.  If not, that could be a
fundamental problem, but at least it prevents doing long searches.

    Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

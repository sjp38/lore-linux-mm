Received: from ns.firmix.at (localhost [127.0.0.1])
	by ns.firmix.at (8.13.6/8.13.6) with ESMTP id l72E6lPC032467
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 2 Aug 2007 16:06:49 +0200
Received: (from defang@localhost)
	by ns.firmix.at (8.13.6/8.13.6/Submit) id l72E6l0Z032461
	for <linux-mm@kvack.org>; Thu, 2 Aug 2007 16:06:47 +0200
Subject: Re: [PATCH] type safe allocator
From: Bernd Petrovitsch <bernd@firmix.at>
In-Reply-To: <1186062476.12034.115.camel@twins>
References: <E1IGAAI-0006K6-00@dorka.pomaz.szeredi.hu>
	 <E1IGYuK-0001Jj-00@dorka.pomaz.szeredi.hu>
	 <b6fcc0a0708020504j7588061fq7e70a50499dcbdfe@mail.gmail.com>
	 <1186062476.12034.115.camel@twins>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 16:06:45 +0200
Message-Id: <1186063605.8085.82.camel@tara.firmix.at>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>, Miklos Szeredi <miklos@szeredi.hu>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 15:47 +0200, Peter Zijlstra wrote:
> On Thu, 2007-08-02 at 16:04 +0400, Alexey Dobriyan wrote:
> > On 8/2/07, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > > The linux kernel doesn't have a type safe object allocator a-la new()
> > > in C++ or g_new() in glib.
> > >
> > > Introduce two helpers for this purpose:
> > >
> > >    alloc_struct(type, gfp_flags);
> > >
> > >    zalloc_struct(type, gfp_flags);
> > 
> > ick.
> > 
> > > These macros take a type name (usually a 'struct foo') as first
> > > argument
> > 
> > So one has to type struct twice.
> 
> thrice in some cases like alloc_struct(struct task_struct, GFP_KERNEL)

Save the explicit "struct" and put it into the macro (and force people
to not use typedefs).

#define alloc_struct(type, flags) ((type *)kmalloc(sizeof(struct type), (flags)))

Obious drawback: We may need alloc_union().

SCNR ...
	Bernd
-- 
Firmix Software GmbH                   http://www.firmix.at/
mobil: +43 664 4416156                 fax: +43 1 7890849-55
          Embedded Linux Development and Services


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

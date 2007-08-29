Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id l7TMKLaa012982
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 15:20:21 -0700
Received: from an-out-0708.google.com (ancc18.prod.google.com [10.100.29.18])
	by zps76.corp.google.com with ESMTP id l7TMKAJS009096
	for <linux-mm@kvack.org>; Wed, 29 Aug 2007 15:20:10 -0700
Received: by an-out-0708.google.com with SMTP id c18so85321anc
        for <linux-mm@kvack.org>; Wed, 29 Aug 2007 15:20:10 -0700 (PDT)
Message-ID: <6599ad830708291520t2bc9ea20m2bdcd9e042b3a423@mail.gmail.com>
Date: Wed, 29 Aug 2007 15:20:09 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface
In-Reply-To: <1188425894.28903.140.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
	 <1188413148.28903.113.camel@localhost>
	 <46D5ED5C.9030405@linux.vnet.ibm.com>
	 <1188425894.28903.140.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

On 8/29/07, Dave Hansen <haveblue@us.ibm.com> wrote:
> On Thu, 2007-08-30 at 03:34 +0530, Balbir Singh wrote:
> > I've thought about this before. The problem is that a user could
> > set his limit to 10000 bytes, but would then see the usage and
> > limit round to the closest page boundary. This can be confusing
> > to a user.
>
> True, but we're lying if we allow a user to set their limit there,
> because we can't actually enforce a limit at 8,192 bytes vs 10,000.
> They're the same limit as far as the kernel is concerned.
>
> Why not just -EINVAL if the value isn't page-aligned?  There are plenty
> of interfaces in the kernel that require userspace to know the page
> size, so this shouldn't be too difficult.

I'd argue that having the user's specified limit be truncated to the
page size is less confusing than giving an EINVAL if it's not page
aligned.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: by nf-out-0910.google.com with SMTP id h3so1371817nfh.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2008 08:54:59 -0800 (PST)
Message-ID: <2c0942db0802200854t64e9ac73g41f0031f4cd995d4@mail.gmail.com>
Date: Wed, 20 Feb 2008 08:54:59 -0800
From: "Ray Lee" <ray-lk@madrabbit.org>
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller in Kconfig
In-Reply-To: <47BC4554.10304@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220122338.GA4352@basil.nowhere.org>
	 <47BC2275.4060900@linux.vnet.ibm.com>
	 <18364.16552.455371.242369@stoffel.org>
	 <47BC4554.10304@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: John Stoffel <john@stoffel.org>, Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2008 at 7:20 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> John Stoffel wrote:
>  > I know this is a pedantic comment, but why the heck is it called such
>  > a generic term as "Memory Controller" which doesn't give any
>  > indication of what it does.
>  >
>  > Shouldn't it be something like "Memory Quota Controller", or "Memory
>  > Limits Controller"?
>  >
>
>  It's called the memory controller since it controls the amount of memory that a
>  user can allocate (via limits). The generic term for any resource manager
>  plugged into cgroups is a controller. If you look through some of the references
>  in the document, we've listed our plans to support other categories of memory as
>  well. Hence it's called a memory controller

While logical, the term is too generic. Memory [Allocation] Governor
might be closer. Memory Quota Controller actually matches the already
established terminology (quotas).

Regardless, Andi's point remains: At minimum, the kconfig text needs
to be clear for distributors and end-users as to why they'd want to
enable this, or what reasons would cause them to not enable it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

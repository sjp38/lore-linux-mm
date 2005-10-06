Received: from e1.ny.us.ibm.com ([192.168.1.101])
	by pokfb.esmtp.ibm.com (8.12.11/8.12.11) with ESMTP id j96ExmFl032470
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 10:59:55 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j96EuZpi029063
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 10:56:35 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j96EuZvf101856
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 10:56:35 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j96EuZrY012752
	for <linux-mm@kvack.org>; Thu, 6 Oct 2005 10:56:35 -0400
Subject: Re: [PATCH] i386: srat and numaq cleanup
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <aec7e5c30510060329kb59edagb619f00b8a58bf3e@mail.gmail.com>
References: <20051005083846.4308.37575.sendpatchset@cherry.local>
	 <1128530262.26009.27.camel@localhost>
	 <aec7e5c30510060329kb59edagb619f00b8a58bf3e@mail.gmail.com>
Content-Type: text/plain
Date: Thu, 06 Oct 2005 07:56:25 -0700
Message-Id: <1128610585.8401.15.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus.damm@gmail.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-10-06 at 19:29 +0900, Magnus Damm wrote:
> On 10/6/05, Dave Hansen <haveblue@us.ibm.com> wrote:
> > I'm highly suspicious of any "cleanup" that adds more code than it
> > deletes.  What does this clean up?
>
> The patch removes #ifdefs from get_memcfg_numa() and introduces an
> inline get_zholes_size(). The #ifdefs are moved down one level to the
> files srat.h and numaq.h and empty inline functions are added. These
> empty inline function are probably the reason for the added lines.

It does remove two #ifdefs, but it adds two #else blocks in other
places.

I also noticed that acpi20_parse_srat() can fail.  So, has_srat may
belong in that function, not in get_memcfg_from_srat()

Why ever have this block?

> +       if ((ret = get_zholes_size_numaq(nid)))
> +               return ret;

get_zholes_size_numaq() is *ALWAYS* empty/false, right?  There's no need
to have a stub for it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

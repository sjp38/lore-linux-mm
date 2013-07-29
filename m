Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 5B57E6B0034
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 10:36:18 -0400 (EDT)
Received: by mail-la0-f48.google.com with SMTP id hi8so4032117lab.21
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 07:36:16 -0700 (PDT)
Date: Mon, 29 Jul 2013 18:36:14 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on file pages
Message-ID: <20130729143614.GN2524@moon>
References: <20130726201807.GJ8661@moon>
 <51F67777.6060609@parallels.com>
 <20130729141417.GM2524@moon>
 <51F67B27.9040004@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51F67B27.9040004@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Mon, Jul 29, 2013 at 06:24:39PM +0400, Pavel Emelyanov wrote:
> 
> For non-x86 case there are stubs in include/asm-generic/pgtable.h that would
> act as if the CONFIG_MEM_SOFT_DIRTY is off.

Yeah, thanks, I'll update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 8C0B76B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 17:28:59 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so3669620ied.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 14:28:59 -0700 (PDT)
Date: Thu, 25 Oct 2012 14:28:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <20121025111411.GB24886@redhat.com>
Message-ID: <alpine.LNX.2.00.1210251427570.3623@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121025111411.GB24886@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 25 Oct 2012, Dave Jones wrote:
> On Wed, Oct 24, 2012 at 09:36:27PM -0700, Hugh Dickins wrote:
> 
>  > Clutching at straws, I expect this is entirely irrelevant, but:
>  > there isn't a warning on line 1151 of mm/shmem.c in 3.7.0-rc2 nor
>  > in current linux.git; rather, there's a VM_BUG_ON on line 1149.
>  > 
>  > So you've inserted a couple of lines for some reason (more useful
>  > trinity behaviour, perhaps)? 
> 
> detritus from the recent mpol_to_str bug that I was chasing.
> Shouldn't be relevant...
> 
>  > And have some config option I'm
>  > unfamiliar with, that mutates a BUG_ON or VM_BUG_ON into a warning?
> 
> Yes, I do have this..
> 
> -#define VM_BUG_ON(cond) BUG_ON(cond)
> +#define VM_BUG_ON(cond) WARN_ON(cond)
> 
> because I got tired of things not going over my usb serial port when I hit them
> a while ago. BUG_ON is pretty unfriendly to bug finding.

Makes sense, thanks for the reassurance.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 519186B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 10:31:42 -0400 (EDT)
Received: from WorldClient by digidescorp.com (MDaemon PRO v10.1.1)
	with ESMTP id md50001436032.msg
	for <linux-mm@kvack.org>; Fri, 01 Oct 2010 09:31:40 -0500
Date: Fri, 01 Oct 2010 09:31:39 -0500
From: "Steve Magnani" <steve@digidescorp.com>
Subject: Re: [PATCH][RESEND] nommu: add anonymous page memcg accounting
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Message-ID: <WC20101001143139.810346@digidescorp.com>
In-Reply-To: <5206.1285943095@redhat.com>
References: <1285929315-2856-1-git-send-email-steve@digidescorp.com> <5206.1285943095@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

David Howells <dhowells@redhat.com> wrote:
> 
> Do we really need to do memcg accounting in NOMMU mode?  Might it be
> better to just apply the attached patch instead?
> 
> David
> ---
> diff --git a/init/Kconfig b/init/Kconfig
> index 2de5b1c..aecff10 100644
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -555,7 +555,7 @@ config RESOURCE_COUNTERS
>  
>  config CGROUP_MEM_RES_CTLR
>  	bool "Memory Resource Controller for Control Groups"
> -	depends on CGROUPS && RESOURCE_COUNTERS
> +	depends on CGROUPS && RESOURCE_COUNTERS && MMU
>  	select MM_OWNER
>  	help
>  	  Provides a memory resource controller that manages both anonymous

If anything I think nommu is one of the better applications of memcg. Since nommu typically == 
embedded, being able to put potential memory pigs in a sandbox so they can't destabilize the 
system is a Good Thing. That was my motivation for doing this in the first place and it works 
quite well.

If it would be better to make nommu memcg contingent on some new Kconfig option, we can do 
that. 

Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

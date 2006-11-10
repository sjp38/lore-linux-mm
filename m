Message-ID: <455442B6.30800@openvz.org>
Date: Fri, 10 Nov 2006 12:13:26 +0300
From: Pavel Emelianov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 7/8] RSS controller fix resource groups parsing
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com> <20061109193627.21437.88058.sendpatchset@balbir.in.ibm.com>
In-Reply-To: <20061109193627.21437.88058.sendpatchset@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@in.ibm.com>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> echo adds a "\n" to the end of a string. When this string is copied from
> user space, we need to remove it, so that match_token() can parse
> the user space string correctly
> 
> Signed-off-by: Balbir Singh <balbir@in.ibm.com>
> ---
> 
>  kernel/res_group/rgcs.c |    6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff -puN kernel/res_group/rgcs.c~container-res-groups-fix-parsing kernel/res_group/rgcs.c
> --- linux-2.6.19-rc2/kernel/res_group/rgcs.c~container-res-groups-fix-parsing	2006-11-09 23:08:10.000000000 +0530
> +++ linux-2.6.19-rc2-balbir/kernel/res_group/rgcs.c	2006-11-09 23:08:10.000000000 +0530
> @@ -241,6 +241,12 @@ ssize_t res_group_file_write(struct cont
>  	}
>  	buf[nbytes] = 0;	/* nul-terminate */
>  
> +	/*
> +	 * Ignore "\n". It might come in from echo(1)

Why not inform user he should call echo -n?

> +	 */
> +	if (buf[nbytes - 1] == '\n')
> +		buf[nbytes - 1] = 0;
> +
>  	container_manage_lock();
>  
>  	if (container_is_removed(cont)) {
> _
> 

That's the same patch as in [PATCH 1/8] mail. Did you attached
a wrong one?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

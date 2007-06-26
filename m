Date: Tue, 26 Jun 2007 15:55:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3] audit: rework execve audit
Message-Id: <20070626155541.9708eded.akpm@linux-foundation.org>
In-Reply-To: <20070613100834.897301179@chello.nl>
References: <20070613100334.635756997@chello.nl>
	<20070613100834.897301179@chello.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, linux-audit@redhat.com
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007 12:03:36 +0200
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> +#ifdef CONFIG_AUDITSYSCALL
> +	{
> +		.ctl_name	= CTL_UNNUMBERED,
> +		.procname	= "audit_argv_kb",
> +		.data		= &audit_argv_kb,
> +		.maxlen		= sizeof(int),
> +		.mode		= 0644,
> +		.proc_handler	= &proc_dointvec,
> +	},
> +#endif

Please document /proc entries in Documentation/filesystems/proc.txt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

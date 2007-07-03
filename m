Subject: Re: [patch 2/3] audit: rework execve audit
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070626155541.9708eded.akpm@linux-foundation.org>
References: <20070613100334.635756997@chello.nl>
	 <20070613100834.897301179@chello.nl>
	 <20070626155541.9708eded.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Tue, 03 Jul 2007 17:00:55 +0200
Message-Id: <1183474855.7054.2.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>, linux-audit@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, 2007-06-26 at 15:55 -0700, Andrew Morton wrote:
> On Wed, 13 Jun 2007 12:03:36 +0200
> Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > +#ifdef CONFIG_AUDITSYSCALL
> > +	{
> > +		.ctl_name	= CTL_UNNUMBERED,
> > +		.procname	= "audit_argv_kb",
> > +		.data		= &audit_argv_kb,
> > +		.maxlen		= sizeof(int),
> > +		.mode		= 0644,
> > +		.proc_handler	= &proc_dointvec,
> > +	},
> > +#endif
> 
> Please document /proc entries in Documentation/filesystems/proc.txt



Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 Documentation/filesystems/proc.txt |    7 +++++++
 1 file changed, 7 insertions(+)

Index: linux-2.6/Documentation/filesystems/proc.txt
===================================================================
--- linux-2.6.orig/Documentation/filesystems/proc.txt
+++ linux-2.6/Documentation/filesystems/proc.txt
@@ -1075,6 +1075,13 @@ check the amount of free space (value is
 resume it  if we have a value of 3 or more percent; consider information about
 the amount of free space valid for 30 seconds
 
+audit_argv_kb
+-------------
+
+The file contains a single value denoting the limit on the argv array size
+for execve (in KiB). This limit is only applied when system call auditing for
+execve is enabled, otherwise the value is ignored.
+
 ctrl-alt-del
 ------------
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

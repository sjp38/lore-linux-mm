Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id BF6E46B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 08:04:57 -0500 (EST)
Received: by lahi5 with SMTP id i5so2978219lah.14
        for <linux-mm@kvack.org>; Mon, 05 Dec 2011 05:04:55 -0800 (PST)
Date: Mon, 5 Dec 2011 15:04:43 +0200 (EET)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 09/11] slab, lockdep: Fix silly bug
In-Reply-To: <20111204190021.812654254@goodmis.org>
Message-ID: <alpine.LFD.2.02.1112051503400.8257@tux.localdomain>
References: <20111204185444.411298317@goodmis.org> <20111204190021.812654254@goodmis.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: linux-kernel@vger.kernel.org, linux-rt-users <linux-rt-users@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Carsten Emde <C.Emde@osadl.org>, John Kacur <jkacur@redhat.com>, stable@kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hans Schillstrom <hans@schillstrom.com>, Christoph Lameter <cl@gentwo.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Sun, 4 Dec 2011, Steven Rostedt wrote:
> --00GvhwF7k39YY
> Content-Type: text/plain; charset="UTF-8"
> Content-Transfer-Encoding: quoted-printable
>
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>
> Commit 30765b92 ("slab, lockdep: Annotate the locks before using
> them") moves the init_lock_keys() call from after g_cpucache_up =3D
> FULL, to before it. And overlooks the fact that init_node_lock_keys()
> tests for it and ignores everything !FULL.
>
> Introduce a LATE stage and change the lockdep test to be <LATE.
>
> Cc: stable@kernel.org
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Hans Schillstrom <hans@schillstrom.com>
> Cc: Christoph Lameter <cl@gentwo.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Matt Mackall <mpm@selenic.com>
> Cc: Sitsofe Wheeler <sitsofe@yahoo.com>
> Cc: linux-mm@kvack.org
> Cc: David Rientjes <rientjes@google.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
> Link: http://lkml.kernel.org/n/tip-gadqbdfxorhia1w5ewmoiodd@git.kernel.org
> Signed-off-by: Steven Rostedt <rostedt@goodmis.org>

Your emails seem to be damaged in interesting ways.

I assume the patch is going through the lockdep tree? If so, please make 
sure you include Christoph's ACK in the changelog.

 			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

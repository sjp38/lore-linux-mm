Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 1AA8F6B0071
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 15:44:17 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so889026lbj.14
        for <linux-mm@kvack.org>; Tue, 10 Jul 2012 12:44:15 -0700 (PDT)
Date: Tue, 10 Jul 2012 22:44:03 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [patch v2] mm, slub: ensure irqs are enabled for kmemcheck
In-Reply-To: <alpine.DEB.2.00.1207091400090.23926@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1207102243540.1899@tux.localdomain>
References: <20120708040009.GA8363@localhost> <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com> <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com> <alpine.LFD.2.02.1207091209220.3050@tux.localdomain>
 <alpine.DEB.2.00.1207090333560.8224@chino.kir.corp.google.com> <1341841593.14828.9.camel@gandalf.stny.rr.com> <alpine.DEB.2.00.1207091400090.23926@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, JoonSoo Kim <js1304@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Vegard Nossum <vegard.nossum@gmail.com>, Christoph Lameter <cl@linux.com>, Rus <rus@sfinxsoft.com>, Ben Hutchings <ben@decadent.org.uk>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 9 Jul 2012, David Rientjes wrote:
> kmemcheck_alloc_shadow() requires irqs to be enabled, so wait to disable
> them until after its called for __GFP_WAIT allocations.
> 
> This fixes a warning for such allocations:
> 
> 	WARNING: at kernel/lockdep.c:2739 lockdep_trace_alloc+0x14e/0x1c0()
> 
> Acked-by: Fengguang Wu <fengguang.wu@intel.com>
> Acked-by: Steven Rostedt <rostedt@goodmis.org>
> Tested-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: David Rientjes <rientjes@google.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

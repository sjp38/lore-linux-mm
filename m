Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id A24CA6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 05:10:00 -0400 (EDT)
Received: by lbjn8 with SMTP id n8so20311793lbj.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 02:09:58 -0700 (PDT)
Date: Mon, 9 Jul 2012 12:09:54 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: WARNING: __GFP_FS allocations with IRQs disabled
 (kmemcheck_alloc_shadow)
In-Reply-To: <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1207091209220.3050@tux.localdomain>
References: <20120708040009.GA8363@localhost> <CAAmzW4OD2_ODyeY7c1VMPajwzovOms5M8Vnw=XP=uGUyPogiJQ@mail.gmail.com> <alpine.DEB.2.00.1207081558540.18461@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: JoonSoo Kim <js1304@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>, Vegard Nossum <vegard.nossum@gmail.com>, Christoph Lameter <cl@linux.com>, Rus <rus@sfinxsoft.com>, Ben Hutchings <ben@decadent.org.uk>, Steven Rostedt <rostedt@goodmis.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 8 Jul 2012, David Rientjes wrote:
> The correct fix is what I proposed at 
> http://marc.info/?l=linux-kernel&m=133754837703630 and was awaiting 
> testing.  If Rus, Steven, or Fengguang could test this then we could add 
> it as a stable backport as well.

Looks good to me. Care to send it my way at penberg@kernel.org? It looks 
like people CC'd me as "penberg@cs.helsinki.fi" which is why I missed it.

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

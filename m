Message-ID: <48084CE4.60109@cs.helsinki.fi>
Date: Fri, 18 Apr 2008 10:25:24 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: 2.6.25-mm1: not looking good
References: <20080417160331.b4729f0c.akpm@linux-foundation.org> <84144f020804172340l79f9c815u42e4dad69dada299@mail.gmail.com> <20080418072457.GB18044@elte.hu>
In-Reply-To: <20080418072457.GB18044@elte.hu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morris <jmorris@namei.org>, Stephen Smalley <sds@tycho.nsa.gov>
List-ID: <linux-mm.kvack.org>

Ingo Molnar wrote:
> hm, there's sel_netnode_free() in the stackframe - that's from 
> security/selinux/netnode.c. Andrew, any recent changes in that area?

Keep in mind that slab might have been corrupted by someone else much 
earlier but we didn't notice due to the lack of CONFIG_SLAB_DEBUG.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

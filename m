Date: Wed, 16 Jul 2003 05:24:54 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.6.0-test1-mm1
Message-ID: <20030716122454.GJ15452@holomorphy.com>
References: <20030715225608.0d3bff77.akpm@osdl.org> <20030716104448.GC25869@ip68-4-255-84.oc.oc.cox.net> <20030716035848.560674ac.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030716035848.560674ac.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Barry K. Nathan" <barryn@pobox.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Barry K. Nathan" <barryn@pobox.com> wrote:
>>  arch/ppc/kernel/irq.c: At top level:  
>>  arch/ppc/kernel/irq.c:575: braced-group within expression allowed only
>>  inside a function

On Wed, Jul 16, 2003 at 03:58:48AM -0700, Andrew Morton wrote:
> Bill?

Building a cross-compiler and taking a stab at fixing it...


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

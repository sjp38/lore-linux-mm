Date: Thu, 10 Jul 2003 01:23:12 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.5.74-mm3 - module-init-tools: necessary to replace root
 copies?
Message-Id: <20030710012312.424b1ca2.akpm@osdl.org>
In-Reply-To: <1057824946.15253.30.camel@www.piet.net>
References: <20030708223548.791247f5.akpm@osdl.org>
	<200307091106.00781.schlicht@uni-mannheim.de>
	<20030709021849.31eb3aec.akpm@osdl.org>
	<1057815890.22772.19.camel@www.piet.net>
	<20030710060841.GQ15452@holomorphy.com>
	<20030710071035.GR15452@holomorphy.com>
	<20030710001853.5a3597b7.akpm@osdl.org>
	<1057824946.15253.30.camel@www.piet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Piet Delaney <piet@www.piet.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Piet Delaney <piet@www.piet.net> wrote:
>
>  Also, do you think it's better to enable the use
>  frame pointer when using kgdb.

Enabled, definitely.

> In the past I thought
>  I had problems with modules due to my enabling the
>  frame pointer being used.

No, there are no such problems.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

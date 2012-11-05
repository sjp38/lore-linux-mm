Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 9C4126B002B
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 10:11:27 -0500 (EST)
Date: Mon, 5 Nov 2012 15:11:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK5 [02/18] slab: Simplify bootstrap
In-Reply-To: <alpine.DEB.2.00.1211021314590.5902@chino.kir.corp.google.com>
Message-ID: <0000013ad1204a8c-e8e9a351-656c-4786-a680-b7f14e2bf075-000000@email.amazonses.com>
References: <20121101214538.971500204@linux.com> <0000013abdf0becf-a3e4ca1c-e164-4445-b1ff-d253af740700-000000@email.amazonses.com> <alpine.DEB.2.00.1211021314590.5902@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, elezegarcia@gmail.com

On Fri, 2 Nov 2012, David Rientjes wrote:

> Needs to update the comment which specifies this is only sized to NR_CPUS.

Ok.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

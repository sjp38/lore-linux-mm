Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id C4B2A6B00F7
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:08:57 -0400 (EDT)
Message-ID: <1337267329.4281.32.camel@twins>
Subject: Re: [PATCH v2 3/3] x86: Support local_flush_tlb_kernel_range
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 17 May 2012 17:08:49 +0200
In-Reply-To: <1337266310.4281.30.camel@twins>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
	 <1337133919-4182-3-git-send-email-minchan@kernel.org>
	 <4FB4B29C.4010908@kernel.org> <1337266310.4281.30.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, x86@kernel.org, Nick Piggin <npiggin@gmail.com>

On Thu, 2012-05-17 at 16:51 +0200, Peter Zijlstra wrote:
>=20
> Also, does it even work if the range happens to be backed by huge pages?
> IIRC we try and do the identity map with large pages wherever possible.=
=20

OK, the Intel SDM seems to suggest it will indeed invalidate ANY mapping
to that linear address, which would include 2M and 1G pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

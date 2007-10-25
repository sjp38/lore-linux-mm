Subject: Re: [patch 3/6] arch_update_pgd call
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <1193345285.7018.21.camel@pasglop>
References: <20071025181520.880272069@de.ibm.com>
	 <20071025181901.591007141@de.ibm.com>  <1193345285.7018.21.camel@pasglop>
Content-Type: text/plain
Date: Fri, 26 Oct 2007 08:49:48 +1000
Message-Id: <1193352588.7018.23.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 2007-10-26 at 06:48 +1000, Benjamin Herrenschmidt wrote:
> I'm not at all fan of the hook there and it's name...

And before somebody jumps on that one.... s/it's/its

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

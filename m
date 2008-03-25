From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] Fix data leak in nobh_write_end.
Date: Tue, 25 Mar 2008 20:22:48 +1100
References: <20080320122953.GA19928@dmon-lap.sw.ru> <20080320123916.GA19995@dmon-lap.sw.ru>
In-Reply-To: <20080320123916.GA19995@dmon-lap.sw.ru>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200803252022.48730.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dmitri Monakhov <dmonakhov@openvz.org>, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thursday 20 March 2008 23:39, Dmitri Monakhov wrote:
> On 15:29 Thu 20 Mar     , root wrote:
> Opps.. sorry for incorrectly filled "FROM:" filed, email was from me.

Thanks for finding this. I guess it was a thinko as to the semantics
of PageMappedToDisk on my behalf...

Reviewed-by: Nick Piggin <npiggin@suse.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Message-ID: <48BEF55E.700@linux-foundation.org>
Date: Wed, 03 Sep 2008 15:36:46 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] buddy: explicitly identify buddy field use in struct
 page
References: <1220467452-15794-1-git-send-email-apw@shadowen.org> <1220467452-15794-4-git-send-email-apw@shadowen.org>
In-Reply-To: <1220467452-15794-4-git-send-email-apw@shadowen.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Andy Whitcroft wrote:
> Explicitly define the struct page fields which buddy uses when it owns
> pages.  Defines a new anonymous struct to allow additional fields to
> be defined in a later patch.

Good. I have a similar patch floating around.

Reviewed-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

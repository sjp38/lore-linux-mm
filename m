Date: Wed, 3 Sep 2008 21:25:22 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: [PATCH 3/4] buddy: explicitly identify buddy field use in
 struct page
Message-ID: <20080903212522.04ab412e@riellaptop.surriel.com>
In-Reply-To: <1220467452-15794-4-git-send-email-apw@shadowen.org>
References: <1220467452-15794-1-git-send-email-apw@shadowen.org>
	<1220467452-15794-4-git-send-email-apw@shadowen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Wed,  3 Sep 2008 19:44:11 +0100
Andy Whitcroft <apw@shadowen.org> wrote:

> Explicitly define the struct page fields which buddy uses when it owns
> pages.  Defines a new anonymous struct to allow additional fields to
> be defined in a later patch.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

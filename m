Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 542A16B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 16:25:28 -0500 (EST)
Message-ID: <50EDE041.1050908@redhat.com>
Date: Wed, 09 Jan 2013 16:25:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 8/8] mm: remove free_area_cache
References: <1357694895-520-1-git-send-email-walken@google.com> <1357694895-520-9-git-send-email-walken@google.com>
In-Reply-To: <1357694895-520-9-git-send-email-walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On 01/08/2013 08:28 PM, Michel Lespinasse wrote:
> Since all architectures have been converted to use vm_unmapped_area(),
> there is no remaining use for the free_area_cache.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

Yay

Acked-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

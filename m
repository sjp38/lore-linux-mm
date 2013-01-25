Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 3FB486B0005
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 22:50:35 -0500 (EST)
Received: from mx3.orcon.net.nz (mx3.orcon.net.nz [219.88.242.53])
	by nctlincom01.orcon.net.nz (8.14.3/8.14.3/Debian-9.4) with ESMTP id r0P3oWHO005901
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 16:50:32 +1300
Received: from Debian-exim by mx3.orcon.net.nz with local (Exim 4.69)
	(envelope-from <mcree@orcon.net.nz>)
	id 1TyaJD-0008Fh-SU
	for linux-mm@kvack.org; Fri, 25 Jan 2013 16:50:31 +1300
Message-Id: <43E02291-8F84-40CD-B429-847E7533EA18@orcon.net.nz>
From: Michael Cree <mcree@orcon.net.nz>
In-Reply-To: <1357694895-520-3-git-send-email-walken@google.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (Apple Message framework v936)
Subject: Re: [PATCH 2/8] mm: use vm_unmapped_area() on alpha architecture
Date: Fri, 25 Jan 2013 16:49:58 +1300
References: <1357694895-520-1-git-send-email-walken@google.com> <1357694895-520-3-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Rik van Riel <riel@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Matt Turner <mattst88@gmail.com>, David Howells <dhowells@redhat.com>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, linux-parisc@vger.kernel.org, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org

On 9/01/2013, at 2:28 PM, Michel Lespinasse wrote:
> Update the alpha arch_get_unmapped_area function to make use of
> vm_unmapped_area() instead of implementing a brute force search.
>
> Signed-off-by: Michel Lespinasse <walken@google.com>

'Tis running fine on my alpha.

Tested-by: Michael Cree <mcree@orcon.net.nz>

Cheers
Michael.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

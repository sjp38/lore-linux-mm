Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id DB1056B0095
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 18:49:27 -0400 (EDT)
Date: Wed, 3 Oct 2012 00:49:21 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 6/8] mm: Make transparent huge code not depend upon the
 details of pgtable_t
Message-ID: <20121002224921.GR4763@redhat.com>
References: <20121002.182718.250164928532772411.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121002.182718.250164928532772411.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org

Hi Dave,

On Tue, Oct 02, 2012 at 06:27:18PM -0400, David Miller wrote:
> 
> The code currently assumes that pgtable_t is a struct page pointer.
> 
> Fix this by pushing pgtable management behind arch helper functions.

This should be fixed in -mm already, it's from the s390x support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

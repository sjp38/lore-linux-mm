Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id F11F06B0078
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:44:27 -0400 (EDT)
Date: Wed, 24 Oct 2012 13:44:26 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH v4 10/10] thp: implement refcounting for huge zero page
Message-ID: <20121024204426.GX2095@tassilo.jf.intel.com>
References: <20121018235941.GA32397@shutemov.name>
 <20121023063532.GA15870@shutemov.name>
 <20121022234349.27f33f62.akpm@linux-foundation.org>
 <20121023070018.GA18381@otc-wbsnb-06>
 <20121023155915.7d5ef9d1.akpm@linux-foundation.org>
 <20121023233801.GA21591@shutemov.name>
 <20121024122253.5ecea992.akpm@linux-foundation.org>
 <20121024194552.GA24460@otc-wbsnb-06>
 <20121024132552.5f9a5f5b.akpm@linux-foundation.org>
 <20121024203329.GA24716@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121024203329.GA24716@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

> Andrea Revieved-by previous version of the patchset, but I've dropped the
> tag after rebase to v3.7-rc1 due not-so-trivial conflicts. Patches 2, 3,
> 4, 7, 10 had conflicts. Mostly due new MMU notifiers interface.

I reviewed it too, but I probably do not count as a real MM person.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

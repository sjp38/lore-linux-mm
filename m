Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id CEDD76B0031
	for <linux-mm@kvack.org>; Mon,  2 Sep 2013 06:56:05 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
References: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
Subject: RE: [PATCH 1/2] mm: thp: cleanup: mv alloc_hugepage to better place
Content-Transfer-Encoding: 7bit
Message-Id: <20130902105540.EBADBE0090@blue.fi.intel.com>
Date: Mon,  2 Sep 2013 13:55:40 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, davidoff@qedmf.net, Bob Liu <bob.liu@oracle.com>

Bob Liu wrote:
> Move alloc_hugepage to better place, no need for a seperate #ifndef CONFIG_NUMA
> 
> Signed-off-by: Bob Liu <bob.liu@oracle.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

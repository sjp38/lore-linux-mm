Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 6F7386B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:10:34 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130716191010.GC4855@linux.intel.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1373885274-25249-2-git-send-email-kirill.shutemov@linux.intel.com>
 <20130716191010.GC4855@linux.intel.com>
Subject: Re: [PATCH 1/8] mm: drop actor argument of do_generic_file_read()
Content-Transfer-Encoding: 7bit
Message-Id: <20130716231327.36ED0E0090@blue.fi.intel.com>
Date: Wed, 17 Jul 2013 02:13:27 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>, Andreas Dilger <andreas.dilger@intel.com>, Peng Tao <tao.peng@emc.com>, Oleg Drokin <oleg.drokin@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Matthew Wilcox wrote:
> On Mon, Jul 15, 2013 at 01:47:47PM +0300, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > There's only one caller of do_generic_file_read() and the only actor is
> > file_read_actor(). No reason to have a callback parameter.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Acked-by: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Would it make sense to do the same thing to do_shmem_file_read()?
> 
> From: Matthew Wilcox <willy@linux.intel.com>
> 
> There's only one caller of do_shmem_file_read() and the only actor is
> file_read_actor(). No reason to have a callback parameter.
> 
> Signed-off-by: Matthew Wilcox <willy@linux.intel.com>

Looks good to me:

Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

v3.11-rc1 brings one more user for read_actor_t -- lustre. But it seemes
it's artifact of ages when f_op had ->sendfile and it's not in use
anymore.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

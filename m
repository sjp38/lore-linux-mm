Date: Sun, 25 Mar 2007 16:00:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/3] only allow nonlinear vmas for ram backed
 filesystems
Message-Id: <20070325160050.fe7cb284.akpm@linux-foundation.org>
In-Reply-To: <E1HVEQJ-0006gF-00@dorka.pomaz.szeredi.hu>
References: <E1HVEOB-0006fX-00@dorka.pomaz.szeredi.hu>
	<E1HVEQJ-0006gF-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Mar 2007 23:09:19 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> Dirty page accounting/limiting doesn't work for nonlinear mappings,

Doesn't it?  iirc the problem is that we don't correctly re-clean the ptes
while starting writeout.  And the dirty-page accounting is in fact correct
(it'd darn well better be).

> so
> for non-ram backed filesystems emulate with linear mappings.  This
> retains ABI compatibility with previous kernels at minimal code cost.
> 
> All known users of nonlinear mappings actually use tmpfs, so this
> shouldn't have any negative effect.

Unless someone is using remap_file_pages() against an ext3 file, in which
case their application stops working?

That would be a problem.  These guys:
http://www.technovelty.org/code/linux/fremap.html, for example, will be in
for a little surprise.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

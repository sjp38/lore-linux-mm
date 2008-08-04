From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [rfc][patch 3/3] xfs: use new vmap API
Date: Mon, 4 Aug 2008 20:57:20 +1000
References: <20080728123438.GA13926@wotan.suse.de> <20080728123703.GC13926@wotan.suse.de> <4896A197.3090004@sgi.com>
In-Reply-To: <4896A197.3090004@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200808042057.20607.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lachlan@sgi.com
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, xfs@oss.sgi.com, xen-devel@lists.xensource.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, dri-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Thanks for taking a look. I'll send them over to -mm with patch 1,
then, for some testing.

On Monday 04 August 2008 16:28, Lachlan McIlroy wrote:
> Looks good to me.
>
> Nick Piggin wrote:
> > Implement XFS's large buffer support with the new vmap APIs. See the vmap
> > rewrite patch for some numbers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

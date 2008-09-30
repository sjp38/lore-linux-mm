Date: Tue, 30 Sep 2008 21:33:19 +0200
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [PATCH] slub: reduce total stack usage of slab_err & object_err
Message-ID: <20080930193318.GA31146@logfs.org>
References: <1222787736.2995.24.camel@castor.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1222787736.2995.24.camel@castor.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Christoph Lameter <cl@linux-foundation.org>, penberg <penberg@cs.helsinki.fi>, mpm <mpm@selenic.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 September 2008 16:15:36 +0100, Richard Kennedy wrote:
> 
> I've been trying to build a tool to estimate the maximum stack usage in
> the kernel, & noticed that most of the biggest stack users are the error
> handling routines.

Cool!  I once did the same, although the code has severely bitrotted by
now.  Is the code available somewhere?

JA?rn

-- 
"Error protection by error detection and correction."
-- from a university class

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

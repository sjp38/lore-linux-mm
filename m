Message-ID: <48AEC58A.4010504@linux-foundation.org>
Date: Fri, 22 Aug 2008 08:56:26 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] Show quicklist at meminfo
References: <20080820113559.f559a411.akpm@linux-foundation.org> <2f11576a0808210036icd9b61eue58049f15381bcc8@mail.gmail.com> <20080822100049.F562.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080821212847.f7fc936b.akpm@linux-foundation.org> <20080822132309.GB9501@sgi.com>
In-Reply-To: <20080822132309.GB9501@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> 
> Could we maybe add a per_cpu off-node quicklist and just always free
> that in check_pgt_cache?  That would get us back the freeing of off-node
> page tables.

Yes that is what I suggested and if you check your email from last year then
you will find an internal discussion and patches for such an approach.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

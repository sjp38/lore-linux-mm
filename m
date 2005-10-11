Date: Tue, 11 Oct 2005 11:32:06 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 0/3] Demand faulting for hugetlb
Message-Id: <20051011113206.77e0fc84.akpm@osdl.org>
In-Reply-To: <1129055057.22182.8.camel@localhost.localdomain>
References: <1129055057.22182.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, david@gibson.dropbear.id.au, ak@suse.de, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Adam Litke <agl@us.ibm.com> wrote:
>
> Andrew: Did Andi
>  Kleen's explanation of huge_pages_needed() satisfy?

Spose so.  I trust that it's adequately commented in this version..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
